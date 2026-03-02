"""IOServePhase [Plasma] — Live bar-by-bar model serving with broker execution.

Loads trained model + VecNormalize. Polls for new bars on interval.
Per-bar risk gates: stop-loss, take-profit, model staleness, data freshness.
Broker execution on position change. Graceful shutdown on SIGINT.

Env construction uses identical params from EnvUnit + AssetUnit as IOEvalPhase.
Types are the parity contract, not shared implementation.
"""
import os
import signal
import time
from datetime import datetime, timezone
from pathlib import Path
import numpy as np
import pandas as pd
import yfinance as yf
import gymnasium as gym
import gym_trading_env  # noqa: F401
from stable_baselines3 import PPO, SAC, DQN, A2C
from stable_baselines3.common.vec_env import DummyVecEnv, VecNormalize
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

from Types.PhaseInputTypes.ServeInput.default import ServeInput
from Types.PhaseInputTypes.IngestInput.default import IngestInput
from Types.PhaseInputTypes.FeatureInput.default import FeatureInput
from Types.UnitTypes.EnvUnit.default import EnvUnit, BrokerMode
from Types.UnitTypes.AssetUnit.default import AssetUnit
from Types.UnitTypes.RunUnit.default import RunUnit
from Types.PhaseOutputTypes.ServeOutput.default import ServeOutput, ServeStatus
from Monads.IOIngestPhase.default import run as ingest
from Monads.IOFeaturePhase.default import run as feature

ALGOS = {"PPO": PPO, "SAC": SAC, "DQN": DQN, "A2C": A2C}
INTERVAL_MAP = {1: "1m", 5: "5m", 15: "15m", 30: "30m", 60: "1h", 1440: "1d"}
MIN_BARS = 64
MAX_DATA_AGE_DAYS = 7
SHUTDOWN = False


def _handle_signal(signum, frame):
    global SHUTDOWN
    SHUTDOWN = True


def _fetch_latest_bar(ticker: str, interval: str) -> pd.DataFrame:
    df = yf.download(ticker, period="1d", interval=interval, auto_adjust=True)
    if isinstance(df.columns, pd.MultiIndex):
        df.columns = df.columns.get_level_values(0)
    df.columns = [c.lower() for c in df.columns]
    return df


def _model_age_min(model_path: str) -> int:
    mtime = datetime.fromtimestamp(Path(model_path).stat().st_mtime, tz=timezone.utc)
    return int((datetime.now(timezone.utc) - mtime).total_seconds() / 60)


def _is_market_open(asset: AssetUnit) -> bool:
    if asset.asset_type.value == "crypto":
        return True
    now_utc = datetime.now(timezone.utc)
    now_min = now_utc.hour * 60 + now_utc.minute
    return asset.trade_start_min <= now_min <= asset.trade_end_min


def _execute_broker(ticker: str, target_pos: float, env_base: EnvUnit) -> None:
    if env_base.broker_mode == BrokerMode.sim:
        return

    import warnings
    warnings.filterwarnings("ignore", category=DeprecationWarning)
    from dotenv import load_dotenv
    from alpaca.trading.client import TradingClient
    from alpaca.trading.requests import MarketOrderRequest
    from alpaca.trading.enums import OrderSide, TimeInForce

    load_dotenv("Env/Inputs/.env")
    api_key = os.environ.get("ALPACA_API_KEY", "")
    secret_key = os.environ.get("ALPACA_SECRET_KEY", "")
    is_paper = env_base.broker_mode == BrokerMode.paper
    client = TradingClient(api_key, secret_key, paper=is_paper)

    try:
        positions = {p.symbol: p for p in client.get_all_positions()}
    except Exception:
        positions = {}

    if target_pos > 0.0 and ticker not in positions:
        notional = round(env_base.initial_value * min(target_pos, 1.0), 2)
        if notional > 1.0:
            client.submit_order(MarketOrderRequest(
                symbol=ticker, notional=notional,
                side=OrderSide.BUY, time_in_force=TimeInForce.DAY,
            ))
    elif target_pos == 0.0 and ticker in positions:
        client.close_position(ticker)


def run(
    serve_specs: ServeInput,
    feature_cfg: FeatureInput,
    ingest_cfg: IngestInput,
    env_base: EnvUnit,
    asset: AssetUnit,
    run_base: RunUnit,
) -> ServeOutput:
    if not Path(serve_specs.io_model_path).exists():
        raise ValueError(f"model not found: {serve_specs.io_model_path}")
    if not Path(serve_specs.io_normalize_path).exists():
        raise ValueError(f"normalize not found: {serve_specs.io_normalize_path}")

    signal.signal(signal.SIGINT, _handle_signal)
    signal.signal(signal.SIGTERM, _handle_signal)

    ingest_record = ingest(ingest_cfg, asset, run_base)
    feature_record = feature(ingest_record, feature_cfg, run_base)

    if not Path(feature_record.io_data_path).exists():
        raise ValueError(f"feature data not found: {feature_record.io_data_path}")
    df = pd.read_pickle(feature_record.io_data_path)
    if len(df) < MIN_BARS:
        raise ValueError(f"insufficient bars: {len(df)} < {MIN_BARS}")

    yf_interval = INTERVAL_MAP[asset.interval_min]
    algo_cls = ALGOS[serve_specs.io_algo.value]
    model = algo_cls.load(serve_specs.io_model_path)

    n_bars_served = 0
    n_trades = 0
    prev_pos = 0.0
    cumulative_ret = 0.0
    status = ServeStatus.running

    while not SHUTDOWN and n_bars_served < serve_specs.max_bars:
        if not _is_market_open(asset):
            time.sleep(serve_specs.poll_interval_s)
            continue

        try:
            new_bars = _fetch_latest_bar(asset.io_ticker, yf_interval)
        except Exception:
            time.sleep(serve_specs.poll_interval_s)
            continue

        if len(new_bars) == 0:
            time.sleep(serve_specs.poll_interval_s)
            continue

        latest = new_bars.iloc[[-1]]
        if len(df) > 0 and latest.index[0] <= df.index[-1]:
            time.sleep(serve_specs.poll_interval_s)
            continue

        ingest_record = ingest(ingest_cfg, asset, run_base)
        feature_record = feature(ingest_record, feature_cfg, run_base)
        df = pd.read_pickle(feature_record.io_data_path)

        forward_bars = len(df)

        def _make_serve_env():
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
        serve_env = VecNormalize.load(serve_specs.io_normalize_path, serve_env)
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
                if current_ret_pct <= env_base.stop_loss_pct:
                    break
                if current_ret_pct >= serve_specs.profit_threshold_pct:
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

            render_dir = Path(run_base.output_dir) / "render_logs"
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

        age = _model_age_min(serve_specs.io_model_path)
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

        if cumulative_ret <= env_base.stop_loss_pct:
            pos = 0.0
            status = ServeStatus.stopped

        if threshold_met:
            status = ServeStatus.stopped

        if pos != prev_pos:
            _execute_broker(asset.io_ticker, pos, env_base)
            n_trades += 1
            prev_pos = pos

        n_bars_served += 1

        if status == ServeStatus.stopped:
            break

        time.sleep(serve_specs.poll_interval_s)

    if status == ServeStatus.running:
        status = ServeStatus.completed

    if SHUTDOWN and prev_pos > 0.0:
        _execute_broker(asset.io_ticker, 0.0, env_base)
        n_trades += 1
        prev_pos = 0.0

    return ServeOutput(
        run_id=run_base.run_id, io_ticker=asset.io_ticker,
        n_bars_served=n_bars_served,
        portfolio_return_pct=max(-100.0, min(1000.0, cumulative_ret)),
        position_taken=max(-10.0, min(10.0, prev_pos)),
        n_trades=n_trades, status=status,
    )


class Settings(BaseSettings):
    """IOServePhase Settings [Plasma] — Standalone entrypoint for live bar-by-bar serving."""
    model_config = SettingsConfigDict(
        json_file="Monads/IOServePhase/default.json",
        json_file_encoding="utf-8",
        env_file="Env/Inputs/.env",
        cli_parse_args=True,
        cli_prog_name="serve",
    )
    asset: AssetUnit = Field(..., description="Asset index — ticker, interval, trade hours, holidays")
    run: RunUnit = Field(default=RunUnit(), description="Run context — ID, seed, output dir, status")
    env: EnvUnit = Field(default=EnvUnit(), description="Trading environment — fees, positions, stop-loss, broker mode")
    serve: ServeInput = Field(..., description="Serve config — model path, normalize path, algo, poll interval")
    feature: FeatureInput = Field(default=FeatureInput(), description="Feature config — wavelet, trend indicators, regime threshold")
    ingest: IngestInput = Field(default=IngestInput(), description="Ingest config — lookback period, warmup, cache dir")

    @classmethod
    def settings_customise_sources(cls, settings_cls, **kwargs):
        from pydantic_settings import JsonConfigSettingsSource, CliSettingsSource
        return (
            CliSettingsSource(settings_cls, cli_parse_args=True),
            JsonConfigSettingsSource(settings_cls),
        )


if __name__ == "__main__":
    s = Settings()
    record = run(s.serve, s.feature, s.ingest, s.env, s.asset, s.run)
    out = Path(s.run.output_dir)
    out.mkdir(parents=True, exist_ok=True)
    (out / f"serve_{s.run.run_ts}_{s.run.run_id}.json").write_text(record.model_dump_json(indent=2))
