"""IOTrainPhase [QGP] — FeatureProductOutput + TrainHom -> TrainProductOutput.

SubprocVecEnv when n_envs > 1 and sim mode. DummyVecEnv otherwise.
VecNormalize for obs/reward. MlpPolicy hardcoded. SB3 logs to store/blobs/{run_id}/logs/.
Reads feature blob from store via StoreMonad.get(). Writes model + normalize blobs via store.put().
"""

from pathlib import Path
from datetime import datetime, timezone
from typing import Callable
import numpy as np
import pandas as pd
import gymnasium as gym
import gym_trading_env  # noqa: F401
from stable_baselines3 import PPO, SAC, DQN, A2C
from stable_baselines3.common.vec_env import DummyVecEnv, SubprocVecEnv, VecNormalize
from stable_baselines3.common.logger import configure
from pydantic import Field
from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
)

from Types.Inductive.Algo.default import AlgoIdentity
from Types.Identity.Asset.default import AssetIdentity
from Types.Identity.Run.default import RunIdentity
from Types.Dependent.Env.default import EnvDependent, BrokerMode
from Types.Hom.Train.default import TrainHom
from Types.Monad.Error.default import ErrorMonad, PhaseId, Severity
from Types.Monad.Store.default import StoreMonad
from Types.Product.Train.Meta.default import TrainProductMeta
from Types.Product.Train.Output.default import TrainProductOutput
from Types.Product.Feature.Output.default import FeatureProductOutput
from Types.IO.IOIngestPhase.default import run as ingest
from Types.IO.IOFeaturePhase.default import run as feature

ALGOS = {"PPO": PPO, "SAC": SAC, "DQN": DQN, "A2C": A2C}


def _make_env(
    df: pd.DataFrame, env_base: EnvDependent, episode_bars: int, verbose: int
) -> Callable[[], gym.Env]:
    def _init() -> gym.Env:
        return gym.make(
            "TradingEnv",
            df=df,
            positions=env_base.positions,
            portfolio_initial_value=float(env_base.initial_value),
            initial_position=0.0,
            trading_fees=env_base.fees_pct / 100.0,
            borrow_interest_rate=env_base.borrow_rate_pct / 100.0,
            windows=None,
            max_episode_duration=episode_bars,
            name=env_base.broker_mode.value,
            verbose=verbose,
            render_mode=None,
        )

    return _init


def run(
    feature_record: FeatureProductOutput,
    train_specs: TrainHom,
    env_base: EnvDependent,
    asset: AssetIdentity,
    run_base: RunIdentity,
    df_slice: pd.DataFrame,
    store_base: StoreMonad,
) -> TrainProductOutput:
    started = datetime.now(timezone.utc).isoformat()
    meta = TrainProductMeta()
    meta.obs.started_at = started
    meta.obs.phase = PhaseId.train

    if len(df_slice) == 0:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.train,
                message="empty DataFrame for training",
                severity=Severity.error,
            )
        )
        raise ValueError("empty DataFrame for training")

    store = store_base.model_copy(
        update={"run_id": run_base.run_id, "phase": PhaseId.train}
    )
    episode_bars = train_specs.episode_duration_min // asset.interval_min

    env_fns = [
        _make_env(df_slice, env_base, episode_bars, run_base.verbose)
        for _ in range(train_specs.n_envs)
    ]
    use_subproc = train_specs.n_envs > 1 and env_base.broker_mode == BrokerMode.sim
    vec_cls = SubprocVecEnv if use_subproc else DummyVecEnv

    try:
        train_env = vec_cls(env_fns)
        train_env = VecNormalize(
            train_env,
            norm_obs=train_specs.normalize_obs,
            norm_reward=train_specs.normalize_reward,
        )
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.train,
                message=f"env creation failed: {str(e)[:128]}",
                severity=Severity.error,
            )
        )
        raise

    try:
        log_dir = Path(store.blob_dir) / run_base.run_id / "logs"
        log_dir.mkdir(parents=True, exist_ok=True)

        algo_cls = ALGOS[train_specs.algo.value]

        import torch

        meta.gpu_used = torch.cuda.is_available()

        model = algo_cls(
            "MlpPolicy",
            train_env,
            learning_rate=train_specs.learning_rate,
            seed=run_base.seed,
            verbose=run_base.verbose,
        )
        logger = configure(
            str(log_dir / f"{run_base.run_ts}_{run_base.run_id}"), ["csv"]
        )
        model.set_logger(logger)

        model.learn(total_timesteps=train_specs.total_timesteps)

        for fmt in logger.output_formats:
            fmt.close()

        if hasattr(train_env, "returns") and len(train_env.returns) > 0:
            meta.episodes_completed = len(train_env.returns)
            meta.mean_episode_reward = float(np.mean(train_env.returns))
            meta.std_episode_reward = float(np.std(train_env.returns))

        final_reward = 0.0
        if hasattr(train_env, "returns") and len(train_env.returns) > 0:
            final_reward = float(train_env.returns[-1])
        final_reward = float(np.clip(final_reward, -1e6, 1e6))

        model_blob = store.blob_path_for("model", ext="zip")
        normalize_blob = store.blob_path_for("normalize", ext="pkl")

        # SB3 appends .zip automatically — save without extension then record with .zip
        model_path_no_ext = str(model_blob).removesuffix(".zip")
        model.save(model_path_no_ext)
        train_env.save(str(normalize_blob))

    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.train,
                message=f"training failed: {str(e)[:128]}",
                severity=Severity.error,
            )
        )
        raise
    finally:
        train_env.close()

    completed = datetime.now(timezone.utc)
    meta.obs.completed_at = completed.isoformat()
    meta.obs.duration_s = (
        completed - datetime.fromisoformat(started.replace("Z", "+00:00"))
    ).total_seconds()

    record = TrainProductOutput(
        run_id=run_base.run_id,
        algo=train_specs.algo,
        total_timesteps=train_specs.total_timesteps,
        final_reward=final_reward,
        meta=meta,
    )

    try:
        # model blob: SB3 writes {path}.zip
        store.put("model", record, blob_path=str(model_blob))
        store.put("normalize", record, blob_path=str(normalize_blob))
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.train,
                message=f"store.put failed: {str(e)[:128]}",
                severity=Severity.error,
            )
        )

    return record


class Settings(BaseSettings):
    """IOTrainPhase Settings [Plasma] — Standalone entrypoint for RL training (5 fields)."""

    model_config = SettingsConfigDict(
        json_file="Types/IO/IOTrainPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="cata-train",
    )
    asset: AssetIdentity = Field(
        ..., description="Asset index — ticker, interval, trade hours, holidays"
    )
    run: RunIdentity = Field(
        default=RunIdentity(), description="Run context — ID, seed, store"
    )
    env: EnvDependent = Field(
        default=EnvDependent(),
        description="Trading environment — fees, positions, stop-loss, broker mode",
    )
    train: TrainHom = Field(
        default=TrainHom(),
        description="Train config — algorithm, timesteps, learning rate, envs",
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

        return (
            CliSettingsSource(settings_cls, cli_parse_args=True),
            JsonConfigSettingsSource(settings_cls),
        )


if __name__ == "__main__":
    from Types.Hom.Ingest.default import IngestHom
    from Types.Hom.Feature.default import FeatureHom

    s = Settings()
    ingest_record = ingest(IngestHom(), s.asset, s.run, s.store)
    feature_record = feature(ingest_record, FeatureHom(), s.run, s.store)
    # Load feature blob from store
    store = s.store.model_copy(
        update={"run_id": s.run.run_id, "phase": PhaseId.feature}
    )
    feat_row = store.get(s.run.run_id, PhaseId.feature.value, "features")
    df = pd.read_pickle(feat_row.blob_path)
    episode_bars = s.train.episode_duration_min // s.asset.interval_min
    df_slice = df.iloc[: episode_bars + 1].copy()
    run(feature_record, s.train, s.env, s.asset, s.run, df_slice, s.store)
