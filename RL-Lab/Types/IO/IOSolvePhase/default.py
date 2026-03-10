"""IOSolvePhase [QGP] — TransformProductOutput + SolveHom -> SolveProductOutput.

SubprocVecEnv when n_parallel > 1 and sim mode. DummyVecEnv otherwise.
VecNormalize for obs/reward. MlpPolicy hardcoded. SB3 logs to store/blobs/{session_id}/logs/.
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

from Types.Inductive.Solver.default import SolverInductive
from Types.Identity.Index.default import IndexIdentity
from Types.Identity.Session.default import SessionIdentity
from Types.Dependent.Execution.default import ExecutionDependent, ExecutionMode
from Types.Hom.Solve.default import SolveHom
from Types.Monad.Error.default import ErrorMonad, PhaseId, Severity
from Types.Monad.Store.default import StoreMonad
from returns.io import IOFailure
from Types.Product.Solve.Meta.default import SolveProductMeta
from Types.Product.Solve.Output.default import SolveProductOutput
from Types.Product.Transform.Output.default import TransformProductOutput
from Types.IO.IOIngestPhase.default import run as ingest
from Types.IO.IOTransformPhase.default import run as feature

ALGOS = {"PPO": PPO, "SAC": SAC, "DQN": DQN, "A2C": A2C}


def _make_env(
    df: pd.DataFrame, env_base: ExecutionDependent, episode_bars: int, verbose: int
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
            name=env_base.execution_mode.value,
            verbose=verbose,
            render_mode=None,
        )

    return _init


def run(
    feature_record: TransformProductOutput,
    train_specs: SolveHom,
    env_base: ExecutionDependent,
    asset: IndexIdentity,
    run_base: SessionIdentity,
    df_slice: pd.DataFrame,
    store_base: StoreMonad,
) -> SolveProductOutput:
    started = datetime.now(timezone.utc).isoformat()
    meta = SolveProductMeta()
    meta.obs.started_at = started
    meta.obs.phase = PhaseId.solve

    if len(df_slice) == 0:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.solve,
                message="empty DataFrame for training",
                severity=Severity.error,
            )
        )
        raise ValueError("empty DataFrame for training")

    store = store_base.model_copy(
        update={"session_id": run_base.session_id, "phase": PhaseId.solve}
    )
    episode_bars = train_specs.horizon_min // asset.interval_min

    env_fns = [
        _make_env(df_slice, env_base, episode_bars, run_base.verbose)
        for _ in range(train_specs.n_parallel)
    ]
    use_subproc = (
        train_specs.n_parallel > 1 and env_base.execution_mode == ExecutionMode.sim
    )
    vec_cls = SubprocVecEnv if use_subproc else DummyVecEnv

    try:
        train_env = vec_cls(env_fns)
        train_env = VecNormalize(
            train_env,
            norm_obs=train_specs.normalize_input,
            norm_reward=train_specs.normalize_signal,
        )
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.solve,
                message=f"env creation failed: {str(e)[:128]}",
                severity=Severity.error,
            )
        )
        raise

    try:
        log_dir = Path(store.blob_dir) / run_base.session_id / "logs"
        log_dir.mkdir(parents=True, exist_ok=True)

        algo_cls = ALGOS[train_specs.solver.value]

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
            str(log_dir / f"{run_base.session_ts}_{run_base.session_id}"), ["csv"]
        )
        model.set_logger(logger)

        model.learn(budget=train_specs.budget)

        for fmt in logger.output_formats:
            fmt.close()

        if hasattr(train_env, "returns") and len(train_env.returns) > 0:
            meta.episodes_completed = len(train_env.returns)
            meta.mean_episode_reward = float(np.mean(train_env.returns))
            meta.std_episode_reward = float(np.std(train_env.returns))

            # B12: Detect reward plateau — if the last 25% of episodes have
            # near-zero variance, the model has converged or is stuck.
            returns = np.array(train_env.returns)
            tail_start = max(0, len(returns) - len(returns) // 4)
            if tail_start > 0 and len(returns[tail_start:]) >= 2:
                tail_std = float(np.std(returns[tail_start:]))
                if tail_std < 1e-4:
                    meta.early_stopped = True

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
                phase=PhaseId.solve,
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

    record = SolveProductOutput(
        session_id=run_base.session_id,
        algo=train_specs.solver,
        budget=train_specs.budget,
        final_reward=final_reward,
        meta=meta,
    )

    try:
        # model blob: SB3 writes {path}.zip
        r1 = store.put("model", record, blob_path=str(model_blob))
        r2 = store.put("normalize", record, blob_path=str(normalize_blob))
        for r in (r1, r2):
            if isinstance(r, IOFailure):
                meta.obs.errors.append(
                    ErrorMonad(
                        phase=PhaseId.solve,
                        message=f"store.put failed: {str(r.failure())[:128]}",
                        severity=Severity.error,
                    )
                )
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.solve,
                message=f"store.put failed: {str(e)[:128]}",
                severity=Severity.error,
            )
        )

    return record


class Settings(BaseSettings):
    """IOSolvePhase Settings [Plasma] — Standalone entrypoint for RL training (5 fields)."""

    model_config = SettingsConfigDict(
        json_file="Types/IO/IOSolvePhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="cata-solve",
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
    solve: SolveHom = Field(
        default=SolveHom(),
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
        from pathlib import Path as _P

        sources = [CliSettingsSource(settings_cls, cli_parse_args=True)]
        _local = _P(__file__).parent / "local.json"
        if _local.exists():
            sources.append(JsonConfigSettingsSource(settings_cls, json_file=_local))
        sources.append(JsonConfigSettingsSource(settings_cls))
        return tuple(sources)


if __name__ == "__main__":
    from Types.Hom.Ingest.default import IngestHom
    from Types.Hom.Transform.default import TransformHom

    s = Settings()
    ingest_record = ingest(IngestHom(), s.asset, s.run, s.store)
    feature_record = feature(ingest_record, TransformHom(), s.run, s.store)
    # Load feature blob from store
    store = s.store.model_copy(
        update={"session_id": s.run.session_id, "phase": PhaseId.transform}
    )
    feat_row = store.get(s.run.session_id, PhaseId.transform.value, "features")
    df = pd.read_pickle(feat_row.blob_path)
    episode_bars = s.train.horizon_min // s.asset.interval_min
    df_slice = df.iloc[: episode_bars + 1].copy()
    run(feature_record, s.train, s.env, s.asset, s.run, df_slice, s.store)
