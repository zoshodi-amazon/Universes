"""IOInferPhase [Plasma] — TrainOutput + InferInput -> InferOutput.

Same env as Train/Eval. Loads model + VecNormalize.
Per-step stop-loss and take-profit check.
Pre-broker gates: model staleness (X4), data freshness (D1), bar count (D2), feature geometry (D3).
Broker position sizing capped to initial_value (R4).
"""
import os
from datetime import datetime, timezone
from pathlib import Path
import pandas as pd
import gymnasium as gym
import gym_trading_env  # noqa: F401
from stable_baselines3 import PPO, SAC, DQN, A2C
from stable_baselines3.common.vec_env import DummyVecEnv, VecNormalize
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

from Types.PhaseInputTypes.InferInput.default import InferInput
from Types.PhaseInputTypes.IngestInput.default import IngestInput
from Types.PhaseInputTypes.FeatureInput.default import FeatureInput
from Types.PhaseInputTypes.TrainInput.default import TrainInput
from Types.UnitTypes.EnvUnit.default import EnvUnit, BrokerMode
from Types.UnitTypes.AssetUnit.default import AssetUnit
from Types.UnitTypes.RunUnit.default import RunUnit
from Types.PhaseOutputTypes.InferOutput.default import InferOutput
from Types.PhaseOutputTypes.TrainOutput.default import TrainOutput
from Types.PhaseOutputTypes.IngestOutput.default import IngestOutput
from Types.PhaseOutputTypes.FeatureOutput.default import FeatureOutput
from Monads.IOIngestPhase.default import run as ingest
from Monads.IOFeaturePhase.default import run as feature
from Monads.IOTrainPhase.default import run as train

ALGOS = {"PPO": PPO, "SAC": SAC, "DQN": DQN, "A2C": A2C}
MIN_BARS = 360
MAX_DATA_AGE_DAYS = 7


def _execute_broker(record: InferOutput, env_base: EnvUnit) -> None:
    """Post-loop broker hook. Submits order to Alpaca for paper/live modes."""
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

    ticker = record.io_ticker
    target_pos = record.position_taken

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
    train_record: TrainOutput,
    infer_specs: InferInput,
    env_base: EnvUnit,
    asset: AssetUnit,
    run_base: RunUnit,
    model_age_min: int,
    df_slice: pd.DataFrame,
    ingest_record: IngestOutput,
    feature_record: FeatureOutput,
) -> InferOutput:
    forward_bars = infer_specs.forward_steps_min // asset.interval_min

    def _make_env():
        return gym.make(
            "TradingEnv", df=df_slice, positions=env_base.positions,
            portfolio_initial_value=float(env_base.initial_value),
            initial_position=env_base.positions[0],
            trading_fees=env_base.fees_pct / 100.0,
            borrow_interest_rate=env_base.borrow_rate_pct / 100.0,
            windows=None, max_episode_duration=forward_bars,
            name=env_base.broker_mode.value, verbose=run_base.verbose, render_mode=None,
        )

    infer_env = DummyVecEnv([_make_env])
    infer_env = VecNormalize.load(train_record.io_normalize_path, infer_env)
    infer_env.training = False
    infer_env.norm_reward = False

    algo_cls = ALGOS[train_record.algo.value]
    model = algo_cls.load(train_record.io_model_path)

    obs = infer_env.reset()
    done = False
    final_info = {}
    threshold_met = False
    while not done:
        action, _ = model.predict(obs, deterministic=True)
        obs, reward, dones, infos = infer_env.step(action)
        done = dones[0]
        final_info = infos[0]

        current_value = final_info.get("portfolio_valuation", env_base.initial_value)
        current_ret_pct = ((current_value - env_base.initial_value) / env_base.initial_value) * 100.0
        if current_ret_pct <= env_base.stop_loss_pct:
            break
        if current_ret_pct >= infer_specs.profit_threshold_pct:
            threshold_met = True
            break

    final_value = final_info.get("portfolio_valuation", env_base.initial_value)
    ret_pct = ((final_value - env_base.initial_value) / env_base.initial_value) * 100.0
    pos = float(final_info.get("position", 0.0))
    infer_env.close()

    if model_age_min > infer_specs.max_model_age_min:
        pos = 0.0

    end_date = datetime.fromisoformat(ingest_record.io_end_date[:10])
    data_age_days = (datetime.now(timezone.utc).date() - end_date.date()).days
    if data_age_days > MAX_DATA_AGE_DAYS:
        pos = 0.0

    if ingest_record.n_bars < MIN_BARS:
        pos = 0.0

    if feature_record.n_static_features != len(feature_record.feature_names):
        pos = 0.0

    record = InferOutput(
        run_id=run_base.run_id, io_ticker=asset.io_ticker,
        position_taken=max(-10.0, min(10.0, pos)),
        portfolio_return_pct=max(-100.0, min(1000.0, ret_pct)),
        model_age_min=model_age_min, broker_mode=env_base.broker_mode,
        threshold_met=threshold_met or ret_pct >= infer_specs.profit_threshold_pct,
    )

    _execute_broker(record, env_base)
    return record


class Settings(BaseSettings):
    """IOInferPhase Settings [Plasma] — Standalone entrypoint for inference (runs ingest → feature → train first)."""
    model_config = SettingsConfigDict(
        json_file="Monads/IOInferPhase/default.json",
        json_file_encoding="utf-8",
        env_file="Env/.env",
        cli_parse_args=True,
        cli_prog_name="infer",
    )
    asset: AssetUnit = Field(..., description="Asset index — ticker, interval, trade hours, holidays")
    run: RunUnit = Field(default=RunUnit(), description="Run context — ID, seed, output dir, status")
    env: EnvUnit = Field(default=EnvUnit(), description="Trading environment — fees, positions, stop-loss, broker mode")
    ingest_cfg: IngestInput = Field(default=IngestInput(), description="Ingest config — lookback period, warmup, cache dir")
    feature_cfg: FeatureInput = Field(default=FeatureInput(), description="Feature config — wavelet, trend indicators, regime threshold")
    train_cfg: TrainInput = Field(default=TrainInput(), description="Train config — algorithm, timesteps, learning rate, envs")
    infer: InferInput = Field(default=InferInput(), description="Infer config — model age limit, forward window, profit threshold")

    @classmethod
    def settings_customise_sources(cls, settings_cls, **kwargs):
        from pydantic_settings import JsonConfigSettingsSource, CliSettingsSource
        return (
            CliSettingsSource(settings_cls, cli_parse_args=True),
            JsonConfigSettingsSource(settings_cls),
        )


if __name__ == "__main__":
    s = Settings()
    ingest_record = ingest(s.ingest_cfg, s.asset, s.run)
    feature_record = feature(ingest_record, s.feature_cfg, s.run)
    df = pd.read_pickle(feature_record.io_data_path)
    episode_bars = s.train_cfg.episode_duration_min // s.asset.interval_min
    infer_bars = s.infer.forward_steps_min // s.asset.interval_min
    train_slice = df.iloc[:episode_bars + 1].copy()
    infer_slice = df.iloc[episode_bars:episode_bars + infer_bars + 1].copy()
    train_record = train(feature_record, s.train_cfg, s.env, s.asset, s.run, train_slice)
    record = run(
        train_record, s.infer, s.env, s.asset, s.run, 0, infer_slice,
        ingest_record, feature_record,
    )
    out = Path(s.run.output_dir)
    out.mkdir(parents=True, exist_ok=True)
    (out / f"infer_{s.run.run_ts}_{s.run.run_id}.json").write_text(record.model_dump_json(indent=2))
