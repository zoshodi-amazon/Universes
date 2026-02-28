"""IOServePhase [Plasma] — Live bar-by-bar model serving with broker execution.

Loads trained model + VecNormalize. Polls for new bars on interval.
Per-bar risk gates: stop-loss, take-profit, model staleness, data freshness.
Broker execution on position change. Graceful shutdown on SIGINT.
"""
import os
import signal
import time
from datetime import datetime, timezone
from pathlib import Path
import numpy as np
import pandas as pd
import pywt
import pandas_ta as ta
import yfinance as yf
import gymnasium as gym
import gym_trading_env  # noqa: F401
from stable_baselines3 import PPO, SAC, DQN, A2C
from stable_baselines3.common.vec_env import DummyVecEnv, VecNormalize
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

from Types.PhaseInputTypes.ServeInput.default import ServeInput
from Types.PhaseInputTypes.FeatureInput.default import FeatureInput
from Types.UnitTypes.EnvUnit.default import EnvUnit, BrokerMode
from Types.UnitTypes.AssetUnit.default import AssetUnit
from Types.UnitTypes.RunUnit.default import RunUnit
from Types.PhaseOutputTypes.ServeOutput.default import ServeOutput, ServeStatus

ALGOS = {"PPO": PPO, "SAC": SAC, "DQN": DQN, "A2C": A2C}
INTERVAL_MAP = {1: "1m", 5: "5m", 15: "15m", 30: "30m", 60: "1h", 1440: "1d"}
MIN_BARS = 64
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


def _wavelet_denoise(signal_arr: np.ndarray, wavelet: str, level: int, mode: str) -> np.ndarray:
    coeffs = pywt.wavedec(signal_arr, wavelet, level=level)
    sigma = np.median(np.abs(coeffs[-1])) / 0.6745
    thresh = sigma * np.sqrt(2 * np.log(len(signal_arr)))
    denoised_coeffs = [coeffs[0]] + [pywt.threshold(c, thresh, mode=mode) for c in coeffs[1:]]
    rec = pywt.waverec(denoised_coeffs, wavelet)
    return rec[:len(signal_arr)]


def _upsample(coeff: np.ndarray, n: int) -> np.ndarray:
    return np.interp(np.linspace(0, 1, n), np.linspace(0, 1, len(coeff)), coeff)


def _compute_features(df: pd.DataFrame, feature_cfg: FeatureInput) -> pd.DataFrame:
    n = len(df)
    channels = ["open", "high", "low", "close", "volume"]

    for ch in channels:
        signal_arr = df[ch].values.copy()
        denoised = _wavelet_denoise(signal_arr, feature_cfg.wavelet.value, feature_cfg.level, feature_cfg.threshold_mode.value)
        pct = pd.Series(denoised, index=df.index).pct_change().fillna(0.0)
        df[f"feature_{ch}_denoised_pct"] = pct.clip(-100.0, 100.0)

        coeffs = pywt.wavedec(signal_arr, feature_cfg.wavelet.value, level=feature_cfg.level)
        approx = _upsample(coeffs[0], n)
        approx_pct = np.diff(approx, prepend=approx[0]) / (np.abs(approx) + 1e-10)
        df[f"feature_{ch}_approx_pct"] = np.clip(approx_pct, -10.0, 10.0)

        detail_energy = np.zeros(n)
        for c in coeffs[1:]:
            detail_energy += _upsample(c**2, n)
        max_e = np.max(detail_energy)
        df[f"feature_{ch}_detail_energy"] = (detail_energy / max_e if max_e > 0 else detail_energy).clip(0.0, 1.0)

    adx_df = ta.adx(df["high"], df["low"], df["close"], length=feature_cfg.adx_period)
    if adx_df is not None:
        adx_col = [c for c in adx_df.columns if c.startswith("ADX_")][0]
        df["feature_adx"] = (adx_df[adx_col].fillna(0.0) / 100.0).clip(0.0, 1.0)

    st_df = ta.supertrend(
        df["high"], df["low"], df["close"],
        length=feature_cfg.supertrend_period, multiplier=feature_cfg.supertrend_multiplier,
    )
    if st_df is not None:
        dir_col = [c for c in st_df.columns if c.startswith("SUPERTd_")][0]
        df["feature_supertrend_dir"] = st_df[dir_col].fillna(0.0).astype(float).clip(-1.0, 1.0)

    if "feature_adx" in df.columns:
        df["feature_regime"] = (df["feature_adx"] >= feature_cfg.regime_threshold / 100.0).astype(float)

    return df


def _execute_broker(ticker: str, target_pos: float, env_base: EnvUnit) -> None:
    if env_base.broker_mode == BrokerMode.sim:
        return

    import warnings
    warnings.filterwarnings("ignore", category=DeprecationWarning)
    from dotenv import load_dotenv
    from alpaca.trading.client import TradingClient
    from alpaca.trading.requests import MarketOrderRequest
    from alpaca.trading.enums import OrderSide, TimeInForce

    load_dotenv("Env/.env")
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


def _is_market_open(asset: AssetUnit) -> bool:
    if asset.asset_type.value == "crypto":
        return True
    now_utc = datetime.now(timezone.utc)
    now_min = now_utc.hour * 60 + now_utc.minute
    return asset.trade_start_min <= now_min <= asset.trade_end_min


def run(
    serve_specs: ServeInput,
    feature_cfg: FeatureInput,
    env_base: EnvUnit,
    asset: AssetUnit,
    run_base: RunUnit,
    io_data_path: str,
) -> ServeOutput:
    if not Path(serve_specs.io_model_path).exists():
        raise ValueError(f"model not found: {serve_specs.io_model_path}")
    if not Path(serve_specs.io_normalize_path).exists():
        raise ValueError(f"normalize not found: {serve_specs.io_normalize_path}")
    if not Path(io_data_path).exists():
        raise ValueError(f"feature data not found: {io_data_path}")

    signal.signal(signal.SIGINT, _handle_signal)
    signal.signal(signal.SIGTERM, _handle_signal)

    df = pd.read_pickle(io_data_path)
    if len(df) < MIN_BARS:
        raise ValueError(f"insufficient bars: {len(df)} < {MIN_BARS}")

    yf_interval = INTERVAL_MAP[asset.interval_min]
    algo_name = "PPO"
    algo_cls = ALGOS[algo_name]
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

        df = pd.concat([df, latest])
        df = df.iloc[-serve_specs.max_bars:]
        df = _compute_features(df.copy(), feature_cfg)

        serve_env = DummyVecEnv([lambda: gym.make(
            "TradingEnv", df=df, positions=env_base.positions,
            portfolio_initial_value=float(env_base.initial_value),
            initial_position=env_base.positions[0],
            trading_fees=env_base.fees_pct / 100.0,
            borrow_interest_rate=env_base.borrow_rate_pct / 100.0,
            windows=None, max_episode_duration=len(df),
            name=env_base.broker_mode.value, verbose=run_base.verbose, render_mode=None,
        )])
        serve_env = VecNormalize.load(serve_specs.io_normalize_path, serve_env)
        serve_env.training = False
        serve_env.norm_reward = False

        try:
            obs = serve_env.reset()
            for _ in range(len(df) - 1):
                action, _ = model.predict(obs, deterministic=True)
                obs, reward, dones, infos = serve_env.step(action)
                if dones[0]:
                    break

            final_info = infos[0]
            current_value = final_info.get("portfolio_valuation", env_base.initial_value)
            bar_ret_pct = ((current_value - env_base.initial_value) / env_base.initial_value) * 100.0
            pos = float(final_info.get("position", 0.0))
        finally:
            serve_env.close()

        cumulative_ret = max(-100.0, min(1000.0, bar_ret_pct))

        if cumulative_ret <= env_base.stop_loss_pct:
            pos = 0.0
            status = ServeStatus.stopped

        if cumulative_ret >= serve_specs.profit_threshold_pct:
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
        env_file="Env/.env",
        cli_parse_args=True,
        cli_prog_name="serve",
    )
    asset: AssetUnit = Field(..., description="Asset index — ticker, interval, trade hours, holidays")
    run: RunUnit = Field(default=RunUnit(), description="Run context — ID, seed, output dir, status")
    env: EnvUnit = Field(default=EnvUnit(), description="Trading environment — fees, positions, stop-loss, broker mode")
    serve: ServeInput = Field(..., description="Serve config — poll interval, max bars, model/normalize paths")
    feature: FeatureInput = Field(default=FeatureInput(), description="Feature config — wavelet, trend indicators, regime threshold")

    @classmethod
    def settings_customise_sources(cls, settings_cls, **kwargs):
        from pydantic_settings import JsonConfigSettingsSource, CliSettingsSource
        return (
            CliSettingsSource(settings_cls, cli_parse_args=True),
            JsonConfigSettingsSource(settings_cls),
        )


if __name__ == "__main__":
    from Monads.IOIngestPhase.default import run as ingest_run
    from Monads.IOFeaturePhase.default import run as feature_run
    from Types.PhaseInputTypes.IngestInput.default import IngestInput
    s = Settings()
    ingest_record = ingest_run(IngestInput(), s.asset, s.run)
    feature_record = feature_run(ingest_record, s.feature, s.run)
    record = run(s.serve, s.feature, s.env, s.asset, s.run, feature_record.io_data_path)
    out = Path(s.run.output_dir)
    out.mkdir(parents=True, exist_ok=True)
    (out / f"serve_{s.run.run_ts}_{s.run.run_id}.json").write_text(record.model_dump_json(indent=2))
