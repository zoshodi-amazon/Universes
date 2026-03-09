"""IOMainPhase [QGP] — Phase 7: Full pipeline with optional Optuna optimization.

Discovery -> Ingest -> Feature -> (Train -> Eval)* with walk-forward windowing.
If optimize=True, runs Optuna hyperparameter search over learning rate and timesteps.
All effectful calls wrapped with typed error handling.

Own BaseSettings + default.json. No cross-phase imports for settings.
"""

import time
import uuid
from datetime import datetime, timezone
import numpy as np
import pandas as pd
from pydantic import Field
from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
)

from Types.Identity.Asset.default import AssetIdentity
from Types.Identity.Run.default import RunIdentity
from Types.Dependent.Env.default import EnvDependent
from Types.Dependent.Risk.default import RiskDependent
from Types.Monad.Error.default import ErrorMonad, PhaseId, Severity
from Types.Monad.Store.default import StoreMonad
from Types.Product.Main.Meta.default import MainProductMeta
from Types.Monad.Metric.default import MetricMonad
from Types.Hom.Main.default import MainHom
from Types.Hom.Pipeline.default import PipelineHom
from Types.Product.Main.Output.default import MainProductOutput, MainStatus

from Types.IO.IODiscoveryPhase.default import run as discover
from Types.IO.IOIngestPhase.default import run as ingest
from Types.IO.IOFeaturePhase.default import run as feature
from Types.IO.IOTrainPhase.default import run as train
from Types.IO.IOEvalPhase.default import run as evaluate


class Settings(BaseSettings):
    """IOMainPhase Settings [Plasma] — Composes all phase configs for full pipeline execution."""

    model_config = SettingsConfigDict(
        json_file="Types/IO/IOMainPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="hylo-main",
    )
    asset: AssetIdentity = Field(..., description="Asset configuration")
    run: RunIdentity = Field(default_factory=RunIdentity, description="Run context")
    env: EnvDependent = Field(
        default_factory=EnvDependent, description="Trading environment"
    )
    risk: RiskDependent = Field(
        default_factory=RiskDependent,
        description="Risk gate — stop-loss and take-profit thresholds",
    )
    main: MainHom = Field(
        default_factory=MainHom,
        description="Main phase config — walk-forward + optimization",
    )
    pipeline: PipelineHom = Field(
        default_factory=PipelineHom,
        description="Per-phase Hom configs for pipeline orchestration",
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


def _run_pipeline(
    settings: Settings, trial_train: "TrainHom | None" = None
) -> MainProductOutput:
    """Core pipeline logic shared between standard and optimize modes."""
    import torch

    started = datetime.now(timezone.utc).isoformat()
    meta = MainProductMeta()
    meta.obs.started_at = started
    meta.obs.phase = PhaseId.pipeline

    train_cfg = trial_train if trial_train else settings.pipeline.train

    np.random.seed(settings.run.seed)
    torch.manual_seed(settings.run.seed)

    try:
        discovery_record = discover(
            settings.pipeline.discovery, settings.asset, settings.run, settings.store
        )
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.discovery,
                message=f"discovery failed: {str(e)[:256]}",
                severity=Severity.error,
            )
        )
        meta.obs.completed_at = datetime.now(timezone.utc).isoformat()
        return MainProductOutput(
            run_id=settings.run.run_id,
            n_windows=0,
            win_rate_pct=0.0,
            duration_s=0.0,
            status=MainStatus.failed,
            meta=meta,
        )

    # Collect discovery errors into main meta
    if discovery_record.meta.obs.errors:
        meta.obs.errors.extend(discovery_record.meta.obs.errors)

    if not discovery_record.qualifying_tickers:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.pipeline,
                message="no qualifying tickers",
                severity=Severity.error,
            )
        )
        meta.obs.completed_at = datetime.now(timezone.utc).isoformat()
        return MainProductOutput(
            run_id=settings.run.run_id,
            n_windows=0,
            win_rate_pct=0.0,
            duration_s=0.0,
            status=MainStatus.failed,
            meta=meta,
        )

    chosen = discovery_record.qualifying_tickers[0]
    asset = settings.asset.model_copy(update={"io_ticker": chosen})

    try:
        ingest_record = ingest(
            settings.pipeline.ingest, asset, settings.run, settings.store
        )
        feature_record = feature(
            ingest_record, settings.pipeline.feature, settings.run, settings.store
        )
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.pipeline,
                message=f"data prep failed: {str(e)[:256]}",
                severity=Severity.error,
            )
        )
        meta.obs.completed_at = datetime.now(timezone.utc).isoformat()
        return MainProductOutput(
            run_id=settings.run.run_id,
            n_windows=0,
            win_rate_pct=0.0,
            duration_s=0.0,
            status=MainStatus.failed,
            meta=meta,
        )

    feat_row = settings.store.model_copy(
        update={"run_id": settings.run.run_id, "phase": "feature"}
    ).get(settings.run.run_id, "feature", "features")
    df = pd.read_pickle(feat_row.blob_path)
    train_bars = train_cfg.episode_duration_min // asset.interval_min
    eval_bars = settings.pipeline.eval.forward_steps_min // asset.interval_min
    stride_bars = settings.main.stride_min // asset.interval_min
    split_idx = int(len(df) * settings.main.train_split_pct / 100.0)
    train_pool = df.iloc[:split_idx]
    n_windows = max(0, (len(train_pool) - train_bars - eval_bars) // stride_bars + 1)

    if n_windows == 0:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.pipeline,
                message="not enough data for walk-forward",
                severity=Severity.error,
            )
        )
        meta.obs.completed_at = datetime.now(timezone.utc).isoformat()
        return MainProductOutput(
            run_id=settings.run.run_id,
            n_windows=0,
            win_rate_pct=0.0,
            duration_s=0.0,
            status=MainStatus.failed,
            meta=meta,
        )

    results = []
    for i in range(n_windows):
        start = i * stride_bars
        train_end = start + train_bars
        eval_end = train_end + eval_bars
        train_slice = train_pool.iloc[start : train_end + 1].copy()
        eval_slice = train_pool.iloc[train_end : eval_end + 1].copy()

        try:
            train_record = train(
                feature_record,
                train_cfg,
                settings.env,
                asset,
                settings.run,
                train_slice,
                settings.store,
            )
            eval_record = evaluate(
                train_record,
                settings.pipeline.eval,
                settings.env,
                settings.risk,
                asset,
                settings.run,
                i,
                eval_slice,
                settings.store,
            )
            results.append(eval_record)

            # Collect any errors from sub-phases
            if eval_record.meta.obs.errors:
                meta.obs.errors.extend(eval_record.meta.obs.errors)
        except Exception as e:
            meta.obs.errors.append(
                ErrorMonad(
                    phase=PhaseId.pipeline,
                    message=f"window {i} failed: {str(e)[:256]}",
                    severity=Severity.warn,
                    window_index=i,
                )
            )

    wins = sum(1 for r in results if r.threshold_met)
    win_rate = round(100.0 * wins / len(results), 2) if results else 0.0

    # Add metrics
    meta.obs.metrics.extend(
        [
            MetricMonad(name="n_windows", value=float(len(results))),
            MetricMonad(name="win_rate_pct", value=win_rate),
            MetricMonad(name="wins", value=float(wins)),
        ]
    )

    # Complete timing
    completed = datetime.now(timezone.utc)
    meta.obs.completed_at = completed.isoformat()
    meta.obs.duration_s = (
        completed - datetime.fromisoformat(started.replace("Z", "+00:00"))
    ).total_seconds()

    has_errors = len(meta.obs.errors) > 0
    has_results = len(results) > 0

    if not has_results:
        status = MainStatus.failed
    elif has_errors:
        status = MainStatus.partial
    else:
        status = MainStatus.success

    return MainProductOutput(
        run_id=settings.run.run_id,
        n_windows=len(results),
        win_rate_pct=win_rate,
        duration_s=min(meta.obs.duration_s, 86400.0),
        status=status,
        results=results,
        meta=meta,
    )


def _run_optimize(settings: Settings) -> MainProductOutput:
    """Optuna hyperparameter optimization over pipeline runs."""
    import optuna
    from optuna.storages.journal import JournalStorage, JournalFileBackend

    started = datetime.now(timezone.utc).isoformat()
    meta = MainProductMeta()
    meta.obs.started_at = started
    meta.obs.phase = PhaseId.pipeline

    opt = settings.main.optimize_config

    store = settings.store.model_copy(
        update={"run_id": settings.run.run_id, "phase": "pipeline"}
    )
    journal_path = store.blob_path_for(f"study_{settings.run.run_ts}", "log")

    storage = JournalStorage(JournalFileBackend(str(journal_path)))
    study = optuna.create_study(
        direction="maximize",
        storage=storage,
        study_name=settings.run.run_id,
        load_if_exists=True,
    )

    def objective(trial: optuna.Trial) -> float:
        lr = trial.suggest_float(
            "learning_rate", opt.search_space_lr_min, opt.search_space_lr_max, log=True
        )
        timesteps = trial.suggest_int(
            "total_timesteps",
            opt.search_space_timesteps_min,
            opt.search_space_timesteps_max,
        )

        trial_train = settings.pipeline.train.model_copy(
            update={"learning_rate": lr, "total_timesteps": timesteps}
        )
        trial_run = settings.run.model_copy(update={"run_id": uuid.uuid4().hex[:8]})
        trial_pipeline = settings.pipeline.model_copy(update={"train": trial_train})
        trial_settings = Settings(
            asset=settings.asset,
            run=trial_run,
            env=settings.env,
            risk=settings.risk,
            main=settings.main.model_copy(update={"optimize": False}),
            pipeline=trial_pipeline,
            store=settings.store,
        )

        result = _run_pipeline(trial_settings, trial_train)

        trial.set_user_attr("run_id", trial_run.run_id)

        if opt.objective_metric.value == "win_rate_pct":
            return result.win_rate_pct
        returns = [r.portfolio_return_pct for r in result.results]
        return sum(returns) / len(returns) if returns else 0.0

    optuna.logging.set_verbosity(optuna.logging.WARNING)
    study.optimize(objective, n_trials=opt.n_trials, n_jobs=opt.n_parallel)

    best = study.best_trial

    # Update meta with optimization results
    meta.best_lr = best.params["learning_rate"]
    meta.best_timesteps = best.params["total_timesteps"]
    meta.best_win_rate_pct = max(0.0, min(100.0, best.value)) if best.value else -1.0
    meta.n_completed = len(study.trials)

    # Store journal blob in StoreMonad — IO paths belong in the DB, not Product types
    try:
        store.put("study_log", meta, blob_path=str(journal_path))
    except Exception:
        pass

    # Complete timing
    completed = datetime.now(timezone.utc)
    meta.obs.completed_at = completed.isoformat()
    meta.obs.duration_s = (
        completed - datetime.fromisoformat(started.replace("Z", "+00:00"))
    ).total_seconds()

    return MainProductOutput(
        run_id=settings.run.run_id,
        n_windows=0,
        win_rate_pct=max(0.0, min(100.0, best.value)) if best.value else 0.0,
        duration_s=min(meta.obs.duration_s, 86400.0),
        status=MainStatus.success,
        results=[],
        meta=meta,
    )


def run(settings: Settings) -> MainProductOutput:
    """IOMainPhase entry point — runs pipeline or optimization based on settings."""
    if settings.main.optimize:
        record = _run_optimize(settings)
    else:
        record = _run_pipeline(settings)

    _write(record, settings.run, settings.store)
    return record


def _write(
    record: MainProductOutput, run_base: RunIdentity, store_base: StoreMonad
) -> None:
    store = store_base.model_copy(
        update={"run_id": run_base.run_id, "phase": "pipeline"}
    )
    blob_path = store.blob_path_for(f"main_{run_base.run_ts}", "json")
    blob_path.write_text(record.model_dump_json(indent=2))
    store.put("main", record, str(blob_path))


if __name__ == "__main__":
    run(Settings())
