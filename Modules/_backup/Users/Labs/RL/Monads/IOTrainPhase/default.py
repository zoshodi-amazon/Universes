"""IOTrainPhase [Plasma] — FeatureOutput + TrainInput -> TrainOutput.

SubprocVecEnv when n_envs > 1 and sim mode. DummyVecEnv otherwise.
VecNormalize for obs/reward. MlpPolicy hardcoded. SB3 logs to Env/output/logs/.
Returns TrainOutput only.
"""
from pathlib import Path
import numpy as np
import pandas as pd
import gymnasium as gym
import gym_trading_env  # noqa: F401
from stable_baselines3 import PPO, SAC, DQN, A2C
from stable_baselines3.common.vec_env import DummyVecEnv, SubprocVecEnv, VecNormalize
from stable_baselines3.common.logger import configure
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

from Types.PhaseInputTypes.TrainInput.default import TrainInput
from Types.PhaseInputTypes.IngestInput.default import IngestInput
from Types.PhaseInputTypes.FeatureInput.default import FeatureInput
from Types.UnitTypes.EnvUnit.default import EnvUnit, BrokerMode
from Types.UnitTypes.AssetUnit.default import AssetUnit
from Types.UnitTypes.RunUnit.default import RunUnit
from Types.PhaseOutputTypes.TrainOutput.default import TrainOutput
from Types.PhaseOutputTypes.FeatureOutput.default import FeatureOutput
from Monads.IOIngestPhase.default import run as ingest
from Monads.IOFeaturePhase.default import run as feature

ALGOS = {"PPO": PPO, "SAC": SAC, "DQN": DQN, "A2C": A2C}


def _make_env(df, env_base, episode_bars, verbose):
    def _init():
        return gym.make(
            "TradingEnv", df=df, positions=env_base.positions,
            portfolio_initial_value=float(env_base.initial_value),
            initial_position=0.0,
            trading_fees=env_base.fees_pct / 100.0,
            borrow_interest_rate=env_base.borrow_rate_pct / 100.0,
            windows=None, max_episode_duration=episode_bars,
            name=env_base.broker_mode.value, verbose=verbose, render_mode=None,
        )
    return _init


def run(
    feature_record: FeatureOutput,
    train_specs: TrainInput,
    env_base: EnvUnit,
    asset: AssetUnit,
    run_base: RunUnit,
    df_slice: pd.DataFrame,
) -> TrainOutput:
    if len(df_slice) == 0:
        raise ValueError("empty DataFrame for training")

    episode_bars = train_specs.episode_duration_min // asset.interval_min

    env_fns = [_make_env(df_slice, env_base, episode_bars, run_base.verbose) for _ in range(train_specs.n_envs)]
    use_subproc = train_specs.n_envs > 1 and env_base.broker_mode == BrokerMode.sim
    vec_cls = SubprocVecEnv if use_subproc else DummyVecEnv
    train_env = vec_cls(env_fns)
    train_env = VecNormalize(train_env, norm_obs=train_specs.normalize_obs, norm_reward=train_specs.normalize_reward)

    try:
        out = Path(run_base.output_dir)
        out.mkdir(parents=True, exist_ok=True)
        log_dir = out / "logs"
        log_dir.mkdir(parents=True, exist_ok=True)

        algo_cls = ALGOS[train_specs.algo.value]
        model = algo_cls(
            "MlpPolicy", train_env,
            learning_rate=train_specs.learning_rate, seed=run_base.seed, verbose=run_base.verbose,
        )
        logger = configure(str(log_dir / f"{run_base.run_ts}_{run_base.run_id}"), ["csv"])
        model.set_logger(logger)
        model.learn(total_timesteps=train_specs.total_timesteps)
        for fmt in logger.output_formats:
            fmt.close()

        final_reward = 0.0
        if hasattr(train_env, "returns") and len(train_env.returns) > 0:
            final_reward = float(train_env.returns[-1])
        final_reward = float(np.clip(final_reward, -1e6, 1e6))

        model_path = str(out / f"model_{run_base.run_ts}_{run_base.run_id}")
        model.save(model_path)
        normalize_path = str(out / f"normalize_{run_base.run_ts}_{run_base.run_id}.pkl")
        train_env.save(normalize_path)
    finally:
        train_env.close()

    return TrainOutput(
        run_id=run_base.run_id, io_model_path=model_path + ".zip",
        algo=train_specs.algo, total_timesteps=train_specs.total_timesteps,
        learning_rate=train_specs.learning_rate, final_reward=final_reward,
        io_normalize_path=normalize_path,
    )


class Settings(BaseSettings):
    """IOTrainPhase Settings [Plasma] — Standalone entrypoint for RL training (runs ingest → feature first)."""
    model_config = SettingsConfigDict(
        json_file="Monads/IOTrainPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="train",
    )
    asset: AssetUnit = Field(..., description="Asset index — ticker, interval, trade hours, holidays")
    run: RunUnit = Field(default=RunUnit(), description="Run context — ID, seed, output dir, status")
    env: EnvUnit = Field(default=EnvUnit(), description="Trading environment — fees, positions, stop-loss, broker mode")
    ingest_cfg: IngestInput = Field(default=IngestInput(), description="Ingest config — lookback period, warmup, cache dir")
    feature_cfg: FeatureInput = Field(default=FeatureInput(), description="Feature config — wavelet, trend indicators, regime threshold")
    train: TrainInput = Field(default=TrainInput(), description="Train config — algorithm, timesteps, learning rate, envs")

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
    episode_bars = s.train.episode_duration_min // s.asset.interval_min
    df_slice = df.iloc[:episode_bars + 1].copy()
    run(feature_record, s.train, s.env, s.asset, s.run, df_slice)
