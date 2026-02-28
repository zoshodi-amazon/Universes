"""IOEvalPhase [Plasma] — TrainOutput + EvalInput -> EvalOutput.

Same env as Train. Loads model + VecNormalize.
Per-step stop-loss and take-profit check. Returns EvalOutput only.
"""
import pandas as pd
import gymnasium as gym
from pathlib import Path
import gym_trading_env  # noqa: F401
from stable_baselines3 import PPO, SAC, DQN, A2C
from stable_baselines3.common.vec_env import DummyVecEnv, VecNormalize
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

from Types.PhaseInputTypes.EvalInput.default import EvalInput
from Types.PhaseInputTypes.IngestInput.default import IngestInput
from Types.PhaseInputTypes.FeatureInput.default import FeatureInput
from Types.PhaseInputTypes.TrainInput.default import TrainInput
from Types.UnitTypes.EnvUnit.default import EnvUnit
from Types.UnitTypes.AssetUnit.default import AssetUnit
from Types.UnitTypes.RunUnit.default import RunUnit
from Types.PhaseOutputTypes.EvalOutput.default import EvalOutput
from Types.PhaseOutputTypes.TrainOutput.default import TrainOutput
from Monads.IOIngestPhase.default import run as ingest
from Monads.IOFeaturePhase.default import run as feature
from Monads.IOTrainPhase.default import run as train

ALGOS = {"PPO": PPO, "SAC": SAC, "DQN": DQN, "A2C": A2C}


def run(
    train_record: TrainOutput,
    eval_specs: EvalInput,
    env_base: EnvUnit,
    asset: AssetUnit,
    run_base: RunUnit,
    window_index: int,
    df_slice: pd.DataFrame,
) -> EvalOutput:
    if len(df_slice) == 0:
        raise ValueError("empty DataFrame for eval")
    if not Path(train_record.io_model_path).exists():
        raise ValueError(f"model not found: {train_record.io_model_path}")
    if not Path(train_record.io_normalize_path).exists():
        raise ValueError(f"normalize not found: {train_record.io_normalize_path}")

    forward_bars = eval_specs.forward_steps_min // asset.interval_min

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

    eval_env = DummyVecEnv([_make_env])
    eval_env = VecNormalize.load(train_record.io_normalize_path, eval_env)
    eval_env.training = False
    eval_env.norm_reward = False

    try:
        algo_cls = ALGOS[train_record.algo.value]
        model = algo_cls.load(train_record.io_model_path)

        obs = eval_env.reset()
        done = False
        final_info = {}
        threshold_met = False
        while not done:
            action, _ = model.predict(obs, deterministic=True)
            obs, reward, dones, infos = eval_env.step(action)
            done = dones[0]
            final_info = infos[0]

            current_value = final_info.get("portfolio_valuation", env_base.initial_value)
            current_ret_pct = ((current_value - env_base.initial_value) / env_base.initial_value) * 100.0
            if current_ret_pct <= env_base.stop_loss_pct:
                break
            if current_ret_pct >= eval_specs.profit_threshold_pct:
                threshold_met = True
                break

        final_value = final_info.get("portfolio_valuation", env_base.initial_value)
        ret_pct = ((final_value - env_base.initial_value) / env_base.initial_value) * 100.0
        pos = float(final_info.get("position", 0.0))
    finally:
        eval_env.close()

    return EvalOutput(
        run_id=run_base.run_id, io_ticker=asset.io_ticker, window_index=window_index,
        portfolio_return_pct=max(-100.0, min(1000.0, ret_pct)),
        final_value=max(0.0, min(1e9, final_value)),
        threshold_met=threshold_met or ret_pct >= eval_specs.profit_threshold_pct,
        position=max(-10.0, min(10.0, pos)),
    )


class Settings(BaseSettings):
    """IOEvalPhase Settings [Plasma] — Standalone entrypoint for evaluation (runs ingest → feature → train first)."""
    model_config = SettingsConfigDict(
        json_file="Monads/IOEvalPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="eval",
    )
    asset: AssetUnit = Field(..., description="Asset index — ticker, interval, trade hours, holidays")
    run: RunUnit = Field(default=RunUnit(), description="Run context — ID, seed, output dir, status")
    env: EnvUnit = Field(default=EnvUnit(), description="Trading environment — fees, positions, stop-loss, broker mode")
    ingest_cfg: IngestInput = Field(default=IngestInput(), description="Ingest config — lookback period, warmup, cache dir")
    feature_cfg: FeatureInput = Field(default=FeatureInput(), description="Feature config — wavelet, trend indicators, regime threshold")
    train_cfg: TrainInput = Field(default=TrainInput(), description="Train config — algorithm, timesteps, learning rate, envs")
    eval: EvalInput = Field(default=EvalInput(), description="Eval config — forward window, profit threshold")

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
    eval_bars = s.eval.forward_steps_min // s.asset.interval_min
    train_slice = df.iloc[:episode_bars + 1].copy()
    eval_slice = df.iloc[episode_bars:episode_bars + eval_bars + 1].copy()
    train_record = train(feature_record, s.train_cfg, s.env, s.asset, s.run, train_slice)
    run(train_record, s.eval, s.env, s.asset, s.run, 0, eval_slice)
