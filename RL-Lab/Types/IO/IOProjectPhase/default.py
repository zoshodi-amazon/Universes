"""IOProjectPhase [QGP] — Live bar-by-bar model serving with broker execution.

Loads trained model + VecNormalize from StoreMonad by solve_session_id.
Polls for new bars on interval. Per-bar risk gates + audit logging.
"""

import os
import json
import signal
import time
from datetime import datetime, timezone
from pathlib import Path
from types import FrameType
from typing import Any
import numpy as np
import pandas as pd
import yfinance as yf
import gymnasium as gym
import gym_trading_env  # noqa: F401
from stable_baselines3 import PPO, SAC, DQN, A2C
from stable_baselines3.common.vec_env import DummyVecEnv, VecNormalize
from pydantic import Field
from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
)

from Types.Hom.Project.default import ProjectHom
from Types.Hom.Ingest.default import IngestHom
from Types.Hom.Transform.default import TransformHom
from Types.Dependent.Execution.default import ExecutionDependent, ExecutionMode
from Types.Dependent.Constraint.default import ConstraintDependent
from Types.Identity.Index.default import IndexIdentity
from Types.Identity.Session.default import SessionIdentity
from Types.Monad.Error.default import ErrorMonad, PhaseId, Severity
from Types.Monad.Store.default import StoreMonad
from returns.io import IOFailure
from returns.maybe import Some
from Types.Product.Project.Meta.default import ProjectProductMeta
from Types.Product.Project.Output.default import ProjectProductOutput, ProjectStatus
from Types.Inductive.Frame.default import FrameInductive
from Types.IO.IOIngestPhase.default import run as ingest
from Types.IO.IOTransformPhase.default import run as feature

ALGOS = {"PPO": PPO, "SAC": SAC, "DQN": DQN, "A2C": A2C}
INTERVAL_MAP = {1: "1m", 5: "5m", 15: "15m", 30: "30m", 60: "1h", 1440: "1d"}
MIN_BARS = 64
MAX_DATA_AGE_DAYS = 7
SHUTDOWN = False


def _audit_log(
    run_base: SessionIdentity, store_base: StoreMonad, entry: dict[str, Any]
) -> None:
    """Append trade decision to audit log (JSONL format) under store blobs."""
    audit_dir = Path(store_base.blob_dir) / run_base.session_id / "audit"
    audit_dir.mkdir(parents=True, exist_ok=True)
    audit_path = audit_dir / f"audit_{run_base.session_ts}_{run_base.session_id}.jsonl"
    entry["timestamp"] = datetime.now(timezone.utc).isoformat()
    with open(audit_path, "a") as f:
        f.write(json.dumps(entry) + "\n")


def _handle_signal(signum: int, frame: FrameType | None) -> None:
    global SHUTDOWN
    SHUTDOWN = True


def _fetch_latest_bar(
    ticker: str, interval: str, meta: ProjectProductMeta
) -> pd.DataFrame:
    """Fetch latest bar with typed error handling and FrameInductive validation."""
    try:
        raw_df = yf.download(ticker, period="1d", interval=interval, auto_adjust=True)
        if raw_df is not None and isinstance(raw_df.columns, pd.MultiIndex):
            raw_df.columns = raw_df.columns.get_level_values(0)
        if raw_df is not None:
            raw_df.columns = [c.lower() for c in raw_df.columns]
        meta.broker_calls += 1
        if raw_df is None or raw_df.empty:
            return pd.DataFrame()
        validated = FrameInductive.from_dataframe(raw_df)
        df = validated.to_dataframe(index=raw_df.index if raw_df is not None else None)
        return df
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.project,
                message=f"bar fetch failed: {str(e)[:64]}",
                severity=Severity.warn,
            )
        )
        meta.broker_failures += 1
        return pd.DataFrame()


def _model_age_min(model_path: str) -> int:
    mtime = datetime.fromtimestamp(Path(model_path).stat().st_mtime, tz=timezone.utc)
    return int((datetime.now(timezone.utc) - mtime).total_seconds() / 60)


def _is_market_open(asset: IndexIdentity) -> bool:
    """Check if the market is currently open for this asset, using local timezone."""
    if asset.index_class.value == "crypto":
        return True
    from zoneinfo import ZoneInfo

    # Map asset type to timezone — US stocks use Eastern
    tz_map = {"stock": "America/New_York", "forex": "America/New_York"}
    tz_name = tz_map.get(asset.index_class.value, "America/New_York")
    now_local = datetime.now(ZoneInfo(tz_name))
    # Weekend check (Monday=0 ... Sunday=6)
    if now_local.weekday() >= 5:
        return False
    now_min = now_local.hour * 60 + now_local.minute
    return asset.trade_start_min <= now_min <= asset.trade_end_min


def _execute_broker(
    ticker: str,
    target_pos: float,
    env_base: ExecutionDependent,
    meta: ProjectProductMeta,
) -> None:
    """Execute broker order with typed error handling. Loads credentials from .env."""
    if env_base.execution_mode == ExecutionMode.sim:
        return

    try:
        import warnings

        warnings.filterwarnings("ignore", category=DeprecationWarning)
        from dotenv import load_dotenv
        from alpaca.trading.client import TradingClient
        from alpaca.trading.requests import MarketOrderRequest
        from alpaca.trading.enums import OrderSide, TimeInForce

        load_dotenv()  # loads .env from project root
        api_key = os.environ.get("ALPACA_API_KEY", "")
        secret_key = os.environ.get("ALPACA_SECRET_KEY", "")
        is_paper = env_base.execution_mode == ExecutionMode.paper
        client = TradingClient(api_key, secret_key, paper=is_paper)

        try:
            positions = {p.symbol: p for p in client.get_all_positions()}
        except Exception as e:
            meta.obs.errors.append(
                ErrorMonad(
                    phase=PhaseId.project,
                    message=f"position fetch failed: {str(e)[:64]}",
                    severity=Severity.warn,
                )
            )
            positions = {}

        if target_pos > 0.0 and ticker not in positions:
            # Long entry
            notional = round(env_base.initial_value * min(target_pos, 1.0), 2)
            if notional > 1.0:
                order = client.submit_order(
                    MarketOrderRequest(
                        symbol=ticker,
                        notional=notional,
                        side=OrderSide.BUY,
                        time_in_force=TimeInForce.DAY,
                    )
                )
                meta.orders_submitted += 1
                if order and getattr(order, "status", None) == "filled":
                    meta.orders_filled += 1
        elif target_pos < 0.0 and ticker not in positions:
            # Short entry
            notional = round(env_base.initial_value * min(abs(target_pos), 1.0), 2)
            if notional > 1.0:
                order = client.submit_order(
                    MarketOrderRequest(
                        symbol=ticker,
                        notional=notional,
                        side=OrderSide.SELL,
                        time_in_force=TimeInForce.DAY,
                    )
                )
                meta.orders_submitted += 1
                if order and getattr(order, "status", None) == "filled":
                    meta.orders_filled += 1
        elif target_pos > 0.0 and ticker in positions:
            # Already in a position — check if we need to flip from short to long
            current_side = getattr(positions[ticker], "side", None)
            if current_side and str(current_side).lower() == "short":
                client.close_position(ticker)
                meta.orders_submitted += 1
                notional = round(env_base.initial_value * min(target_pos, 1.0), 2)
                if notional > 1.0:
                    order = client.submit_order(
                        MarketOrderRequest(
                            symbol=ticker,
                            notional=notional,
                            side=OrderSide.BUY,
                            time_in_force=TimeInForce.DAY,
                        )
                    )
                    meta.orders_submitted += 1
                    if order and getattr(order, "status", None) == "filled":
                        meta.orders_filled += 1
        elif target_pos < 0.0 and ticker in positions:
            # Already in a position — check if we need to flip from long to short
            current_side = getattr(positions[ticker], "side", None)
            if current_side and str(current_side).lower() == "long":
                client.close_position(ticker)
                meta.orders_submitted += 1
                notional = round(env_base.initial_value * min(abs(target_pos), 1.0), 2)
                if notional > 1.0:
                    order = client.submit_order(
                        MarketOrderRequest(
                            symbol=ticker,
                            notional=notional,
                            side=OrderSide.SELL,
                            time_in_force=TimeInForce.DAY,
                        )
                    )
                    meta.orders_submitted += 1
                    if order and getattr(order, "status", None) == "filled":
                        meta.orders_filled += 1
        elif target_pos == 0.0 and ticker in positions:
            # Flatten
            client.close_position(ticker)
            meta.orders_submitted += 1
            meta.orders_filled += 1

        meta.broker_calls += 1
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.project,
                message=f"broker execution failed: {str(e)[:64]}",
                severity=Severity.error,
            )
        )
        meta.broker_failures += 1


def run(
    project_specs: ProjectHom,
    env_base: ExecutionDependent,
    risk: ConstraintDependent,
    asset: IndexIdentity,
    run_base: SessionIdentity,
    store_base: StoreMonad,
) -> ProjectProductOutput:
    started = datetime.now(timezone.utc).isoformat()
    meta = ProjectProductMeta()
    meta.obs.started_at = started
    meta.obs.phase = PhaseId.project

    # Each phase handles its own parameterization — defaults used internally
    ingest_cfg = IngestHom()
    feature_cfg = TransformHom()

    # Resolve model + normalize from store using solve_session_id
    store = store_base.model_copy(
        update={"session_id": project_specs.solve_session_id, "phase": PhaseId.solve}
    )
    try:
        model_row = store.get(
            project_specs.solve_session_id, PhaseId.solve.value, "model"
        )
        normalize_row = store.get(
            project_specs.solve_session_id, PhaseId.solve.value, "normalize"
        )
        model_path = model_row.blob_path
        normalize_path = normalize_row.blob_path
    except KeyError as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.project,
                message=f"artifact not found in store: {e}",
                severity=Severity.error,
            )
        )
        raise ValueError(f"artifact not found in store: {e}")

    if not Path(model_path).exists():
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.project,
                message=f"model blob not found: {model_path}",
                severity=Severity.error,
            )
        )
        raise ValueError(f"model blob not found: {model_path}")
    if not Path(normalize_path).exists():
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.project,
                message=f"normalize blob not found: {normalize_path}",
                severity=Severity.error,
            )
        )
        raise ValueError(f"normalize blob not found: {normalize_path}")

    signal.signal(signal.SIGINT, _handle_signal)
    signal.signal(signal.SIGTERM, _handle_signal)

    ingest_record = ingest(ingest_cfg, asset, run_base, store_base)
    feature_record = feature(ingest_record, feature_cfg, run_base, store_base)

    # Load feature blob from store
    feat_store = store_base.model_copy(
        update={"session_id": run_base.session_id, "phase": PhaseId.transform}
    )
    try:
        feat_row = feat_store.get(
            run_base.session_id, PhaseId.transform.value, "features"
        )
        df = pd.read_pickle(feat_row.blob_path)
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.project,
                message=f"feature blob not found: {str(e)[:128]}",
                severity=Severity.error,
            )
        )
        raise ValueError(f"feature blob not found: {str(e)[:128]}")

    if len(df) < MIN_BARS:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.project,
                message=f"insufficient bars: {len(df)} < {MIN_BARS}",
                severity=Severity.error,
            )
        )
        raise ValueError(f"insufficient bars: {len(df)} < {MIN_BARS}")

    yf_interval = INTERVAL_MAP[asset.interval_min]
    algo_cls = ALGOS[project_specs.io_solver.value]
    model = algo_cls.load(model_path)

    n_bars_served = 0
    prev_pos = 0.0
    cumulative_ret = 0.0
    final_value = float(env_base.initial_value)
    max_value_seen = float(env_base.initial_value)
    status = ProjectStatus.running

    while not SHUTDOWN and n_bars_served < project_specs.max_frames:
        if not _is_market_open(asset):
            time.sleep(project_specs.sample_interval_s)
            continue

        new_bars = _fetch_latest_bar(asset.io_ticker, yf_interval, meta)

        if len(new_bars) == 0:
            time.sleep(project_specs.sample_interval_s)
            continue

        latest = new_bars.iloc[[-1]]
        if len(df) > 0 and latest.index[0] <= df.index[-1]:
            time.sleep(project_specs.sample_interval_s)
            continue

        ingest_record = ingest(ingest_cfg, asset, run_base, store_base)
        feature_record = feature(ingest_record, feature_cfg, run_base, store_base)
        try:
            maybe_feat2 = feat_store.get(
                run_base.session_id, PhaseId.transform.value, "features"
            )
            if not isinstance(maybe_feat2, Some):
                raise ValueError("feature reload: not found in store")
            feat_row = maybe_feat2.unwrap()
            df = pd.read_pickle(feat_row.blob_path)
        except Exception as e:
            meta.obs.errors.append(
                ErrorMonad(
                    phase=PhaseId.project,
                    message=f"feature reload failed: {str(e)[:64]}",
                    severity=Severity.warn,
                )
            )
            time.sleep(project_specs.sample_interval_s)
            continue

        def _make_serve_env() -> gym.Env:
            env = gym.make(
                "TradingEnv",
                df=df,
                positions=env_base.positions,
                portfolio_initial_value=float(env_base.initial_value),
                initial_position=0.0,
                trading_fees=env_base.fees_pct / 100.0,
                borrow_interest_rate=env_base.borrow_rate_pct / 100.0,
                windows=None,
                max_episode_duration="max",
                name=env_base.execution_mode.value,
                verbose=run_base.verbose,
                render_mode="logs",
            )
            env.unwrapped.add_metric(
                "Market Return",
                lambda history: f"{((history['data_close', -1] / history['data_close', 0]) - 1) * 100:.2f}%",
            )
            env.unwrapped.add_metric(
                "Position Changes",
                lambda history: np.sum(np.diff(history["position"]) != 0),
            )
            return env

        serve_env = DummyVecEnv([_make_serve_env])
        serve_env = VecNormalize.load(normalize_path, serve_env)
        serve_env.training = False
        serve_env.norm_reward = False

        try:
            obs = serve_env.reset()
            done = False
            final_info = {}
            threshold_met = False
            while not done:
                action, _ = model.predict(obs, deterministic=True)
                obs, reward, dones, infos = serve_env.step(action)
                done = dones[0]
                final_info = infos[0]

                current_value = final_info.get(
                    "portfolio_valuation", env_base.initial_value
                )
                current_ret_pct = (
                    (current_value - env_base.initial_value) / env_base.initial_value
                ) * 100.0
                if current_ret_pct <= risk.stop_loss_pct:
                    break
                if current_ret_pct >= risk.profit_threshold_pct:
                    threshold_met = True
                    break

            final_value = final_info.get("portfolio_valuation", env_base.initial_value)
            bar_ret_pct = (
                (final_value - env_base.initial_value) / env_base.initial_value
            ) * 100.0
            pos = float(final_info.get("position", 0.0))

            flat_idx = env_base.positions.index(0.0)
            if pos != 0.0:
                obs, reward, dones, infos = serve_env.step([flat_idx])
                final_info = infos[0]
                final_value = final_info.get(
                    "portfolio_valuation", env_base.initial_value
                )
                bar_ret_pct = (
                    (final_value - env_base.initial_value) / env_base.initial_value
                ) * 100.0
                pos = 0.0

            render_dir = Path(store_base.blob_dir) / run_base.session_id / "render_logs"
            render_dir.mkdir(parents=True, exist_ok=True)
            try:
                inner_env = serve_env.envs[0].unwrapped
                if hasattr(inner_env, "df") and inner_env.df.index.tz is not None:
                    inner_env.df.index = inner_env.df.index.tz_localize(None)
                inner_env.save_for_render(dir=str(render_dir))
            except Exception as e:
                meta.obs.errors.append(
                    ErrorMonad(
                        phase=PhaseId.project,
                        message=f"render save failed: {str(e)[:64]}",
                        severity=Severity.warn,
                    )
                )
        finally:
            serve_env.close()

        cumulative_ret = max(-100.0, min(1000.0, bar_ret_pct))

        # D8.10: Max drawdown circuit breaker — track peak value, flatten if drawdown exceeds threshold
        max_value_seen = max(max_value_seen, final_value)
        if max_value_seen > 0:
            drawdown_pct = ((final_value - max_value_seen) / max_value_seen) * 100.0
            if drawdown_pct <= risk.max_drawdown_pct:
                pos = 0.0
                status = ProjectStatus.stopped
                meta.shutdown_reason = "max_drawdown"

        age = _model_age_min(model_path)
        if age > project_specs.max_artifact_age_min:
            pos = 0.0

        end_date = df.index[-1]
        if hasattr(end_date, "date"):
            data_age_days = (datetime.now(timezone.utc).date() - end_date.date()).days
        else:
            data_age_days = 0
        if data_age_days > MAX_DATA_AGE_DAYS:
            pos = 0.0

        if len(df) < MIN_BARS:
            pos = 0.0

        feature_names = [c for c in df.columns if c.startswith("feature_")]
        if len(feature_names) == 0:
            pos = 0.0

        if cumulative_ret <= risk.stop_loss_pct:
            pos = 0.0
            status = ProjectStatus.stopped
            meta.shutdown_reason = "stop_loss"

        if threshold_met:
            status = ProjectStatus.stopped
            meta.shutdown_reason = "take_profit"

        if pos != prev_pos:
            _audit_log(
                run_base,
                store_base,
                {
                    "action": "position_change",
                    "ticker": asset.io_ticker,
                    "prev_position": prev_pos,
                    "new_position": pos,
                    "portfolio_value": final_value,
                    "return_pct": cumulative_ret,
                    "execution_mode": env_base.execution_mode.value,
                    "reason": "model_prediction",
                },
            )
            _execute_broker(asset.io_ticker, pos, env_base, meta)
            prev_pos = pos

        n_bars_served += 1

        if status == ProjectStatus.stopped:
            break

        time.sleep(project_specs.sample_interval_s)

    if status == ProjectStatus.running:
        status = ProjectStatus.completed
        meta.shutdown_reason = "completed"

    if SHUTDOWN and prev_pos != 0.0:
        _audit_log(
            run_base,
            store_base,
            {
                "action": "shutdown_flatten",
                "ticker": asset.io_ticker,
                "prev_position": prev_pos,
                "new_position": 0.0,
                "portfolio_value": final_value,
                "return_pct": cumulative_ret,
                "execution_mode": env_base.execution_mode.value,
                "reason": "graceful_shutdown",
            },
        )
        _execute_broker(asset.io_ticker, 0.0, env_base, meta)
        prev_pos = 0.0
        meta.shutdown_reason = "graceful_shutdown"

    completed = datetime.now(timezone.utc)
    meta.obs.completed_at = completed.isoformat()
    meta.obs.duration_s = (
        completed - datetime.fromisoformat(started.replace("Z", "+00:00"))
    ).total_seconds()

    record = ProjectProductOutput(
        session_id=run_base.session_id,
        io_ticker=asset.io_ticker,
        n_bars_served=n_bars_served,
        portfolio_return_pct=max(-100.0, min(1000.0, cumulative_ret)),
        position_taken=max(-10.0, min(10.0, prev_pos)),
        status=status,
        meta=meta,
    )

    # Store serve result
    serve_store = store_base.model_copy(
        update={"session_id": run_base.session_id, "phase": PhaseId.project}
    )
    result = serve_store.put("project", record)
    if isinstance(result, IOFailure):
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.project,
                message=f"store.put failed: {str(result.failure())[:128]}",
                severity=Severity.error,
            )
        )

    return record


class Settings(BaseSettings):
    """IOProjectPhase Settings [Plasma] — Standalone entrypoint for live bar-by-bar serving (6 fields)."""

    model_config = SettingsConfigDict(
        json_file="Types/IO/IOProjectPhase/default.json",
        json_file_encoding="utf-8",
        env_file=".env",
        cli_parse_args=True,
        cli_prog_name="cata-project",
    )
    asset: IndexIdentity = Field(
        ..., description="Asset index — ticker, interval, trade hours, holidays"
    )
    run: SessionIdentity = Field(
        default=SessionIdentity(), description="Run context — ID, seed, store"
    )
    env: ExecutionDependent = Field(
        default=ExecutionDependent(),
        description="Trading environment — fees, positions, stop-loss, broker mode",
    )
    risk: ConstraintDependent = Field(
        default_factory=ConstraintDependent,
        description="Risk gate — stop-loss and take-profit thresholds",
    )
    project: ProjectHom = Field(
        ..., description="Serve config — solve_session_id, algo, poll interval"
    )
    store: StoreMonad = Field(
        default_factory=StoreMonad,
        description="Artifact store — DB + blob dir",
    )

    @classmethod
    def settings_customise_sources(
        cls,
        settings_cls: type[BaseSettings],
        init_settings: PydanticBaseSettingsSource,
        env_settings: PydanticBaseSettingsSource,
        dotenv_settings: PydanticBaseSettingsSource,
        file_secret_settings: PydanticBaseSettingsSource,
    ) -> tuple[PydanticBaseSettingsSource, ...]:
        from pydantic_settings import JsonConfigSettingsSource, CliSettingsSource
        from pathlib import Path as _P

        sources = [CliSettingsSource(settings_cls, cli_parse_args=True)]
        _local = _P(__file__).parent / "local.json"
        if _local.exists():
            sources.append(JsonConfigSettingsSource(settings_cls, json_file=_local))
        sources.append(JsonConfigSettingsSource(settings_cls))
        return tuple(sources)


if __name__ == "__main__":
    s = Settings()
    run(s.serve, s.env, s.risk, s.asset, s.run, s.store)
