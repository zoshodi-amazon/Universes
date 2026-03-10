"""IOComposePhase [QGP] — Phase 7: Full pipeline with optional Optuna optimization.

Discovery -> Ingest -> Feature -> (Train -> Eval)* with walk-forward windowing.
If optimize=True, runs Optuna hyperparameter search over learning rate and timesteps.
All effectful calls wrapped with typed error handling.

Each sub-phase Hom is instantiated locally with defaults — IOComposePhase is a
parameterized wrapper, not a cross-phase config aggregator.
"""

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

from Types.Identity.Index.default import IndexIdentity
from Types.Identity.Session.default import SessionIdentity
from Types.Dependent.Execution.default import ExecutionDependent
from Types.Dependent.Constraint.default import ConstraintDependent
from Types.Monad.Error.default import ErrorMonad, PhaseId, Severity
from Types.Monad.Store.default import StoreMonad
from returns.io import IOFailure
from returns.maybe import Some
from Types.Product.Compose.Meta.default import ComposeProductMeta
from Types.Monad.Measure.default import MeasureMonad
from Types.Hom.Compose.default import ComposeHom
from Types.Hom.Discovery.default import DiscoveryHom
from Types.Hom.Ingest.default import IngestHom
from Types.Hom.Transform.default import TransformHom
from Types.Hom.Solve.default import SolveHom
from Types.Hom.Eval.default import EvalHom
from Types.Product.Compose.Output.default import ComposeProductOutput, ComposeStatus

from Types.IO.IODiscoveryPhase.default import run as discover
from Types.IO.IOIngestPhase.default import run as ingest
from Types.IO.IOTransformPhase.default import run as feature
from Types.IO.IOSolvePhase.default import run as train
from Types.IO.IOEvalPhase.default import run as evaluate


class Settings(BaseSettings):
    """IOComposePhase Settings [Plasma] — Standalone entrypoint for full pipeline execution (6 fields)."""

    model_config = SettingsConfigDict(
        json_file="Types/IO/IOComposePhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="hylo-compose",
    )
    asset: IndexIdentity = Field(..., description="Asset configuration")
    run: SessionIdentity = Field(
        default_factory=SessionIdentity, description="Run context"
    )
    env: ExecutionDependent = Field(
        default_factory=ExecutionDependent, description="Trading environment"
    )
    risk: ConstraintDependent = Field(
        default_factory=ConstraintDependent,
        description="Risk gate — stop-loss and take-profit thresholds",
    )
    compose: ComposeHom = Field(
        default_factory=ComposeHom,
        description="Compose phase config — walk-forward + search",
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


def _run_pipeline(
    settings: Settings, trial_train: "SolveHom | None" = None
) -> ComposeProductOutput:
    """Core pipeline logic shared between standard and optimize modes."""
    import torch

    started = datetime.now(timezone.utc).isoformat()
    meta = ComposeProductMeta()
    meta.obs.started_at = started
    meta.obs.phase = PhaseId.compose

    # Each phase handles its own parameterization — defaults used internally
    discovery_cfg = DiscoveryHom()
    ingest_cfg = IngestHom()
    feature_cfg = TransformHom()
    train_cfg = trial_train if trial_train else SolveHom()
    eval_cfg = EvalHom()

    np.random.seed(settings.run.seed)
    torch.manual_seed(settings.run.seed)

    try:
        discovery_record = discover(
            discovery_cfg, settings.asset, settings.run, settings.store
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
        return ComposeProductOutput(
            session_id=settings.run.session_id,
            n_windows=0,
            win_rate_pct=0.0,
            duration_s=0.0,
            status=ComposeStatus.failed,
            meta=meta,
        )

    # Collect discovery errors into main meta
    if discovery_record.meta.obs.errors:
        meta.obs.errors.extend(discovery_record.meta.obs.errors)

    if not discovery_record.qualifying_tickers:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.compose,
                message="no qualifying tickers",
                severity=Severity.error,
            )
        )
        meta.obs.completed_at = datetime.now(timezone.utc).isoformat()
        return ComposeProductOutput(
            session_id=settings.run.session_id,
            n_windows=0,
            win_rate_pct=0.0,
            duration_s=0.0,
            status=ComposeStatus.failed,
            meta=meta,
        )

    chosen = discovery_record.qualifying_tickers[0]
    asset = settings.asset.model_copy(update={"io_ticker": chosen})

    try:
        ingest_record = ingest(ingest_cfg, asset, settings.run, settings.store)
        feature_record = feature(
            ingest_record, feature_cfg, settings.run, settings.store
        )
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.compose,
                message=f"data prep failed: {str(e)[:256]}",
                severity=Severity.error,
            )
        )
        meta.obs.completed_at = datetime.now(timezone.utc).isoformat()
        return ComposeProductOutput(
            session_id=settings.run.session_id,
            n_windows=0,
            win_rate_pct=0.0,
            duration_s=0.0,
            status=ComposeStatus.failed,
            meta=meta,
        )

    maybe_feat = settings.store.model_copy(
        update={"session_id": settings.run.session_id, "phase": "transform"}
    ).get(settings.run.session_id, "transform", "features")
    if not isinstance(maybe_feat, Some):
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.compose,
                message="feature artifact not found in store",
                severity=Severity.error,
            )
        )
        meta.obs.completed_at = datetime.now(timezone.utc).isoformat()
        return ComposeProductOutput(
            session_id=settings.run.session_id,
            n_windows=0,
            win_rate_pct=0.0,
            duration_s=0.0,
            status=ComposeStatus.failed,
            meta=meta,
        )
    feat_row = maybe_feat.unwrap()
    df = pd.read_pickle(feat_row.blob_path)
    train_bars = train_cfg.horizon_min // asset.interval_min
    eval_bars = eval_cfg.horizon_min // asset.interval_min
    stride_bars = settings.compose.stride_min // asset.interval_min
    split_idx = int(len(df) * settings.compose.solve_split_pct / 100.0)
    train_pool = df.iloc[:split_idx]
    n_windows = max(0, (len(train_pool) - train_bars - eval_bars) // stride_bars + 1)

    if n_windows == 0:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.compose,
                message="not enough data for walk-forward",
                severity=Severity.error,
            )
        )
        meta.obs.completed_at = datetime.now(timezone.utc).isoformat()
        return ComposeProductOutput(
            session_id=settings.run.session_id,
            n_windows=0,
            win_rate_pct=0.0,
            duration_s=0.0,
            status=ComposeStatus.failed,
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
                eval_cfg,
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
                    phase=PhaseId.compose,
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
            MeasureMonad(name="n_windows", value=float(len(results))),
            MeasureMonad(name="win_rate_pct", value=win_rate),
            MeasureMonad(name="wins", value=float(wins)),
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
        status = ComposeStatus.failed
    elif has_errors:
        status = ComposeStatus.partial
    else:
        status = ComposeStatus.success

    return ComposeProductOutput(
        session_id=settings.run.session_id,
        n_windows=len(results),
        win_rate_pct=win_rate,
        duration_s=min(meta.obs.duration_s, 86400.0),
        status=status,
        results=results,
        meta=meta,
    )


def _run_search(settings: Settings) -> ComposeProductOutput:
    """Optuna hyperparameter optimization over pipeline runs."""
    import optuna
    from optuna.storages.journal import JournalStorage, JournalFileBackend

    started = datetime.now(timezone.utc).isoformat()
    meta = ComposeProductMeta()
    meta.obs.started_at = started
    meta.obs.phase = PhaseId.compose

    opt = settings.compose.search_fiber

    store = settings.store.model_copy(
        update={"session_id": settings.run.session_id, "phase": "compose"}
    )
    journal_path = store.blob_path_for(f"study_{settings.run.session_ts}", "log")

    storage = JournalStorage(JournalFileBackend(str(journal_path)))
    study = optuna.create_study(
        direction="maximize",
        storage=storage,
        study_name=settings.run.session_id,
        load_if_exists=True,
    )

    def objective(trial: optuna.Trial) -> float:
        lr = trial.suggest_float(
            "learning_rate", opt.search_space_lr_min, opt.search_space_lr_max, log=True
        )
        timesteps = trial.suggest_int(
            "budget",
            opt.search_space_timesteps_min,
            opt.search_space_timesteps_max,
        )

        trial_train = SolveHom().model_copy(
            update={"learning_rate": lr, "budget": timesteps}
        )
        trial_run = settings.run.model_copy(update={"session_id": uuid.uuid4().hex[:8]})
        trial_settings = Settings(
            asset=settings.asset,
            run=trial_run,
            env=settings.env,
            risk=settings.risk,
            main=settings.compose.model_copy(update={"search": False}),
            store=settings.store,
        )

        result = _run_pipeline(trial_settings, trial_train)

        trial.set_user_attr("session_id", trial_run.session_id)

        if opt.objective_metric.value == "win_rate_pct":
            return result.win_rate_pct
        returns = [r.portfolio_return_pct for r in result.results]
        return sum(returns) / len(returns) if returns else 0.0

    optuna.logging.set_verbosity(optuna.logging.WARNING)
    study.optimize(objective, n_trials=opt.n_trials, n_jobs=opt.n_parallel)

    best = study.best_trial

    # Update meta with optimization results
    meta.best_lr = best.params["learning_rate"]
    meta.best_timesteps = best.params["budget"]
    meta.best_win_rate_pct = max(0.0, min(100.0, best.value)) if best.value else -1.0
    meta.n_completed = len(study.trials)

    # Store journal blob in StoreMonad — IO paths belong in the DB, not Product types
    try:
        result = store.put("study_log", meta, blob_path=str(journal_path))
        if isinstance(result, IOFailure):
            meta.obs.errors.append(
                ErrorMonad(
                    phase=PhaseId.compose,
                    message=f"study journal store.put failed: {str(result.failure())[:128]}",
                    severity=Severity.warn,
                )
            )
    except Exception as e:
        meta.obs.errors.append(
            ErrorMonad(
                phase=PhaseId.compose,
                message=f"study journal store.put failed: {str(e)[:128]}",
                severity=Severity.warn,
            )
        )

    # Complete timing
    completed = datetime.now(timezone.utc)
    meta.obs.completed_at = completed.isoformat()
    meta.obs.duration_s = (
        completed - datetime.fromisoformat(started.replace("Z", "+00:00"))
    ).total_seconds()

    return ComposeProductOutput(
        session_id=settings.run.session_id,
        n_windows=0,
        win_rate_pct=max(0.0, min(100.0, best.value)) if best.value else 0.0,
        duration_s=min(meta.obs.duration_s, 86400.0),
        status=ComposeStatus.success,
        results=[],
        meta=meta,
    )


def run(settings: Settings) -> ComposeProductOutput:
    """IOComposePhase entry point — runs pipeline or optimization based on settings."""
    if settings.compose.search:
        record = _run_search(settings)
    else:
        record = _run_pipeline(settings)

    _write(record, settings.run, settings.store)
    return record


def _write(
    record: ComposeProductOutput, run_base: SessionIdentity, store_base: StoreMonad
) -> None:
    store = store_base.model_copy(
        update={"session_id": run_base.session_id, "phase": "compose"}
    )
    blob_path = store.blob_path_for(f"main_{run_base.session_ts}", "json")
    blob_path.write_text(record.model_dump_json(indent=2))
    result = store.put("main", record, str(blob_path))
    # IOResult checked by caller if needed; _write is a fire-and-forget persist


if __name__ == "__main__":
    run(Settings())
