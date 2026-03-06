"""IOServePhase [QGP] — Live bar-by-bar model serving with broker execution.

Loads trained model + VecNormalize from StoreMonad by train_run_id.
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
from pydantic_settings import BaseSettings, PydanticBaseSettingsSource, SettingsConfigDict

from Types.Hom.Serve.default import ServeHom
from Types.Hom.Ingest.default import IngestHom
from Types.Hom.Feature.default import FeatureHom
from Types.Dependent.Env.default import EnvDependent, BrokerMode
from Types.Dependent.Risk.default import RiskDependent
from Types.Identity.Asset.default import AssetIdentity
from Types.Identity.Run.default import RunIdentity
from Types.Monad.Error.default import ErrorMonad, PhaseId, Severity
from Types.Product.Serve.Meta.default import ServeProductMeta
from Types.Product.Serve.Output.default import ServeProductOutput, ServeStatus
from Types.Inductive.OHLCV.default import OHLCVInductive
from Types.IO.IOIngestPhase.default import run as ingest
from Types.IO.IOFeaturePhase.default import run as feature

ALGOS = {"PPO": PPO, "SAC": SAC, "DQN": DQN, "A2C": A2C}
INTERVAL_MAP = {1: "1m", 5: "5m", 15: "15m", 30: "30m", 60: "1h", 1440: "1d"}
MIN_BARS = 64
MAX_DATA_AGE_DAYS = 7
SHUTDOWN = False


def _audit_log(run_base: RunIdentity, entry: dict[str, Any]) -> None:
    """Append trade decision to audit log (JSONL format) under store blobs."""
    audit_dir = Path(run_base.store.blob_dir) / run_base.run_id / "audit"
    audit_dir.mkdir(parents=True, exist_ok=True)
    audit_path = audit_dir / f"audit_{run_base.run_ts}_{run_base.run_id}.jsonl"
    entry["timestamp"] = datetime.now(timezone.utc).isoformat()
    with open(audit_path, "a") as f:
        f.write(json.dumps(entry) + "\n")


def _handle_signal(signum: int, frame: FrameType | None) -> None:
    global SHUTDOWN
    SHUTDOWN = True


def _fetch_latest_bar(ticker: str, interval: str, meta: ServeProductMeta) -> pd.DataFrame:
    """Fetch latest bar with typed error handling and OHLCVInductive validation."""
    try:
        raw_df = yf.download(ticker, period="1d", interval=interval, auto_adjust=True)
        if raw_df is not None and isinstance(raw_df.columns, pd.MultiIndex):
            raw_df.columns = raw_df.columns.get_level_values(0)
        if raw_df is not None:
            raw_df.columns = [c.lower() for c in raw_df.columns]
        meta.broker_calls += 1
        if raw_df is None or raw_df.empty:
            return pd.DataFrame()
        validated = OHLCVInductive.from_dataframe(raw_df)
        df = validated.to_dataframe(index=raw_df.index if raw_df is not None else None)
        return df
    except Exception as e:
        meta.obs.errors.append(ErrorMonad(
            phase=PhaseId.serve,
            message=f"bar fetch failed: {str(e)[:64]}",
            severity=Severity.warn
        ))
        meta.broker_failures += 1
        return pd.DataFrame()


def _model_age_min(model_path: str) -> int:
    mtime = datetime.fromtimestamp(Path(model_path).stat().st_mtime, tz=timezone.utc)
    return int((datetime.now(timezone.utc) - mtime).total_seconds() / 60)


def _is_market_open(asset: AssetIdentity) -> bool:
    if asset.asset_type.value == "crypto":
        return True
    now_utc = datetime.now(timezone.utc)
    now_min = now_utc.hour * 60 + now_utc.minute
    return asset.trade_start_min <= now_min <= asset.trade_end_min


def _execute_broker(ticker: str, target_pos: float, env_base: EnvDependent, meta: ServeProductMeta) -> None:
    """Execute broker order with typed error handling. Loads credentials from .env."""
    if env_base.broker_mode == BrokerMode.sim:
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
        is_paper = env_base.broker_mode == BrokerMode.paper
        client = TradingClient(api_key, secret_key, paper=is_paper)

        try:
            positions = {p.symbol: p for p in client.get_all_positions()}
        except Exception as e:
            meta.obs.errors.append(ErrorMonad(
                phase=PhaseId.serve,
                message=f"position fetch failed: {str(e)[:64]}",
                severity=Severity.warn
            ))
            positions = {}

        if target_pos > 0.0 and ticker not in positions:
            notional = round(env_base.initial_value * min(target_pos, 1.0), 2)
            if notional > 1.0:
                client.submit_order(MarketOrderRequest(
                    symbol=ticker, notional=notional,
                    side=OrderSide.BUY, time_in_force=TimeInForce.DAY,
                ))
                meta.orders_submitted += 1
                meta.orders_filled += 1
        elif target_pos == 0.0 and ticker in positions:
            client.close_position(ticker)
            meta.orders_submitted += 1
            meta.orders_filled += 1

        meta.broker_calls += 1
    except Exception as e:
        meta.obs.errors.append(ErrorMonad(
            phase=PhaseId.serve,
            message=f"broker execution failed: {str(e)[:64]}",
            severity=Severity.error
        ))
        meta.broker_failures += 1


def run(
    serve_specs: ServeHom,
    feature_cfg: FeatureHom,
    ingest_cfg: IngestHom,
    env_base: EnvDependent,
    risk: RiskDependent,
    asset: AssetIdentity,
    run_base: RunIdentity,
) -> ServeProductOutput:
    started = datetime.now(timezone.utc).isoformat()
    meta = ServeProductMeta()
    meta.obs.started_at = started
    meta.obs.phase = PhaseId.serve

    # Resolve model + normalize from store using train_run_id
    store = run_base.store.model_copy(update={"run_id": serve_specs.train_run_id, "phase": PhaseId.train})
    try:
        model_row = store.get(serve_specs.train_run_id, PhaseId.train.value, "model")
        normalize_row = store.get(serve_specs.train_run_id, PhaseId.train.value, "normalize")
        model_path = model_row.blob_path
        normalize_path = normalize_row.blob_path
    except KeyError as e:
        meta.obs.errors.append(ErrorMonad(
            phase=PhaseId.serve,
            message=f"artifact not found in store: {e}",
            severity=Severity.error
        ))
        raise ValueError(f"artifact not found in store: {e}")

    if not Path(model_path).exists():
        meta.obs.errors.append(ErrorMonad(
            phase=PhaseId.serve,
            message=f"model blob not found: {model_path}",
            severity=Severity.error
        ))
        raise ValueError(f"model blob not found: {model_path}")
    if not Path(normalize_path).exists():
        meta.obs.errors.append(ErrorMonad(
            phase=PhaseId.serve,
            message=f"normalize blob not found: {normalize_path}",
            severity=Severity.error
        ))
        raise ValueError(f"normalize blob not found: {normalize_path}")

    signal.signal(signal.SIGINT, _handle_signal)
    signal.signal(signal.SIGTERM, _handle_signal)

    ingest_record = ingest(ingest_cfg, asset, run_base)
    feature_record = feature(ingest_record, feature_cfg, run_base)

    # Load feature blob from store
    feat_store = run_base.store.model_copy(update={"run_id": run_base.run_id, "phase": PhaseId.feature})
    try:
        feat_row = feat_store.get(run_base.run_id, PhaseId.feature.value, "features")
        df = pd.read_pickle(feat_row.blob_path)
    except (KeyError, Exception) as e:
        meta.obs.errors.append(ErrorMonad(
            phase=PhaseId.serve,
            message=f"feature blob not found: {str(e)[:128]}",
            severity=Severity.error
        ))
        raise ValueError(f"feature blob not found: {str(e)[:128]}")

    if len(df) < MIN_BARS:
        meta.obs.errors.append(ErrorMonad(
            phase=PhaseId.serve,
            message=f"insufficient bars: {len(df)} < {MIN_BARS}",
            severity=Severity.error
        ))
        raise ValueError(f"insufficient bars: {len(df)} < {MIN_BARS}")

    yf_interval = INTERVAL_MAP[asset.interval_min]
    algo_cls = ALGOS[serve_specs.io_algo.value]
    model = algo_cls.load(model_path)

    n_bars_served = 0
    prev_pos = 0.0
    cumulative_ret = 0.0
    final_value = float(env_base.initial_value)
    status = ServeStatus.running

    while not SHUTDOWN and n_bars_served < serve_specs.max_bars:
        if not _is_market_open(asset):
            time.sleep(serve_specs.poll_interval_s)
            continue

        new_bars = _fetch_latest_bar(asset.io_ticker, yf_interval, meta)

        if len(new_bars) == 0:
            time.sleep(serve_specs.poll_interval_s)
            continue

        latest = new_bars.iloc[[-1]]
        if len(df) > 0 and latest.index[0] <= df.index[-1]:
            time.sleep(serve_specs.poll_interval_s)
            continue

        ingest_record = ingest(ingest_cfg, asset, run_base)
        feature_record = feature(ingest_record, feature_cfg, run_base)
        try:
            feat_row = feat_store.get(run_base.run_id, PhaseId.feature.value, "features")
            df = pd.read_pickle(feat_row.blob_path)
        except Exception:
            time.sleep(serve_specs.poll_interval_s)
            continue

        def _make_serve_env() -> gym.Env:
            env = gym.make(
                "TradingEnv", df=df, positions=env_base.positions,
                portfolio_initial_value=float(env_base.initial_value),
                initial_position=0.0,
                trading_fees=env_base.fees_pct / 100.0,
                borrow_interest_rate=env_base.borrow_rate_pct / 100.0,
                windows=None, max_episode_duration="max",
                name=env_base.broker_mode.value, verbose=run_base.verbose, render_mode="logs",
            )
            env.unwrapped.add_metric("Market Return", lambda history: f"{((history['data_close', -1] / history['data_close', 0]) - 1) * 100:.2f}%")
            env.unwrapped.add_metric("Position Changes", lambda history: np.sum(np.diff(history["position"]) != 0))
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

                current_value = final_info.get("portfolio_valuation", env_base.initial_value)
                current_ret_pct = ((current_value - env_base.initial_value) / env_base.initial_value) * 100.0
                if current_ret_pct <= risk.stop_loss_pct:
                    break
                if current_ret_pct >= risk.profit_threshold_pct:
                    threshold_met = True
                    break

            final_value = final_info.get("portfolio_valuation", env_base.initial_value)
            bar_ret_pct = ((final_value - env_base.initial_value) / env_base.initial_value) * 100.0
            pos = float(final_info.get("position", 0.0))

            flat_idx = env_base.positions.index(0.0)
            if pos != 0.0:
                obs, reward, dones, infos = serve_env.step([flat_idx])
                final_info = infos[0]
                final_value = final_info.get("portfolio_valuation", env_base.initial_value)
                bar_ret_pct = ((final_value - env_base.initial_value) / env_base.initial_value) * 100.0
                pos = 0.0

            render_dir = Path(run_base.store.blob_dir) / run_base.run_id / "render_logs"
            render_dir.mkdir(parents=True, exist_ok=True)
            try:
                inner_env = serve_env.envs[0].unwrapped
                if hasattr(inner_env, 'df') and inner_env.df.index.tz is not None:
                    inner_env.df.index = inner_env.df.index.tz_localize(None)
                inner_env.save_for_render(dir=str(render_dir))
            except Exception:
                pass
        finally:
            serve_env.close()

        cumulative_ret = max(-100.0, min(1000.0, bar_ret_pct))

        age = _model_age_min(model_path)
        if age > serve_specs.max_model_age_min:
            pos = 0.0

        end_date = df.index[-1]
        if hasattr(end_date, 'date'):
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
            status = ServeStatus.stopped
            meta.shutdown_reason = "stop_loss"

        if threshold_met:
            status = ServeStatus.stopped
            meta.shutdown_reason = "take_profit"

        if pos != prev_pos:
            _audit_log(run_base, {
                "action": "position_change",
                "ticker": asset.io_ticker,
                "prev_position": prev_pos,
                "new_position": pos,
                "portfolio_value": final_value,
                "return_pct": cumulative_ret,
                "broker_mode": env_base.broker_mode.value,
                "reason": "model_prediction",
            })
            _execute_broker(asset.io_ticker, pos, env_base, meta)
            prev_pos = pos

        n_bars_served += 1

        if status == ServeStatus.stopped:
            break

        time.sleep(serve_specs.poll_interval_s)

    if status == ServeStatus.running:
        status = ServeStatus.completed
        meta.shutdown_reason = "completed"

    if SHUTDOWN and prev_pos > 0.0:
        _audit_log(run_base, {
            "action": "shutdown_flatten",
            "ticker": asset.io_ticker,
            "prev_position": prev_pos,
            "new_position": 0.0,
            "portfolio_value": final_value,
            "return_pct": cumulative_ret,
            "broker_mode": env_base.broker_mode.value,
            "reason": "graceful_shutdown",
        })
        _execute_broker(asset.io_ticker, 0.0, env_base, meta)
        prev_pos = 0.0
        meta.shutdown_reason = "graceful_shutdown"

    completed = datetime.now(timezone.utc)
    meta.obs.completed_at = completed.isoformat()
    meta.obs.duration_s = (completed - datetime.fromisoformat(started.replace('Z', '+00:00'))).total_seconds()

    record = ServeProductOutput(
        run_id=run_base.run_id, io_ticker=asset.io_ticker,
        n_bars_served=n_bars_served,
        portfolio_return_pct=max(-100.0, min(1000.0, cumulative_ret)),
        position_taken=max(-10.0, min(10.0, prev_pos)),
        status=status,
        meta=meta,
    )

    # Store serve result
    serve_store = run_base.store.model_copy(update={"run_id": run_base.run_id, "phase": PhaseId.serve})
    try:
        serve_store.put("serve", record)
    except Exception as e:
        meta.obs.errors.append(ErrorMonad(
            phase=PhaseId.serve,
            message=f"store.put failed: {str(e)[:128]}",
            severity=Severity.error
        ))

    return record


class Settings(BaseSettings):
    """IOServePhase Settings [Plasma] — Standalone entrypoint for live bar-by-bar serving."""
    model_config = SettingsConfigDict(
        json_file="Types/IO/IOServePhase/default.json",
        json_file_encoding="utf-8",
        env_file=".env",
        cli_parse_args=True,
        cli_prog_name="serve",
    )
    asset: AssetIdentity = Field(..., description="Asset index — ticker, interval, trade hours, holidays")
    run: RunIdentity = Field(default=RunIdentity(), description="Run context — ID, seed, store")
    env: EnvDependent = Field(default=EnvDependent(), description="Trading environment — fees, positions, stop-loss, broker mode")
    risk: RiskDependent = Field(default_factory=RiskDependent, description="Risk gate — stop-loss and take-profit thresholds")
    serve: ServeHom = Field(..., description="Serve config — train_run_id, algo, poll interval")
    feature: FeatureHom = Field(default=FeatureHom(), description="Feature config — wavelet, trend indicators, regime threshold")
    ingest: IngestHom = Field(default=IngestHom(), description="Ingest config — lookback period, warmup")

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
        return (
            CliSettingsSource(settings_cls, cli_parse_args=True),
            JsonConfigSettingsSource(settings_cls),
        )


if __name__ == "__main__":
    s = Settings()
    run(s.serve, s.feature, s.ingest, s.env, s.risk, s.asset, s.run)
