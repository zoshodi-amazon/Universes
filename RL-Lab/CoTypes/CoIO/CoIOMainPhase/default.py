"""CoIOMainPhase [CoIO] — Main phase observation executor.

Coalgebraic observer for Phase 7 (QGP, the composite phase). Absorbs:
- Pipeline artifact probing (original)
- Type system structural validation (from dissolved CoIOValidatePhase)
- Cross-phase Rerun visualization (from dissolved IOVisualizePhase)

All cross-cutting observation belongs here because Main IS the composite.
"""

import importlib
import json
import uuid
from datetime import datetime, timezone
from pathlib import Path

from pydantic import BaseModel, Field
from pydantic.fields import FieldInfo
from pydantic_settings import (
    BaseSettings,
    PydanticBaseSettingsSource,
    SettingsConfigDict,
)

from CoTypes.CoHom.Main.default import CoMainHom
from CoTypes.CoProduct.Main.Output.default import CoMainProductOutput
from CoTypes.CoProduct.Main.Meta.default import CoMainProductMeta
from CoTypes.Comonad.Trace.default import TraceComonad, CoPhaseId
from Types.Monad.Store.default import StoreMonad
from Types.Monad.Error.default import PhaseId


# ── Type module registry for import health checks ──────────────────
TYPE_MODULES: list[tuple[str, str]] = [
    # Identity
    ("Types.Identity.Asset.default", "AssetIdentity"),
    ("Types.Identity.Run.default", "RunIdentity"),
    # Inductive
    ("Types.Inductive.Algo.default", "AlgoIdentity"),
    ("Types.Inductive.OHLCV.default", "OHLCVInductive"),
    ("Types.Inductive.Screener.default", "ScreenerInductive"),
    ("Types.Inductive.ScreenerQuote.default", "ScreenerQuoteInductive"),
    ("Types.Inductive.TickerInfo.default", "TickerInfoInductive"),
    # Dependent
    ("Types.Dependent.Env.default", "EnvDependent"),
    ("Types.Dependent.Risk.default", "RiskDependent"),
    ("Types.Dependent.Liquidity.default", "LiquidityDependent"),
    ("Types.Dependent.Alarm.default", "AlarmDependent"),
    ("Types.Dependent.Optimize.default", "OptimizeDependent"),
    # Hom (7 canonical phases only)
    ("Types.Hom.Discovery.default", "DiscoveryHom"),
    ("Types.Hom.Ingest.default", "IngestHom"),
    ("Types.Hom.Feature.default", "FeatureHom"),
    ("Types.Hom.Train.default", "TrainHom"),
    ("Types.Hom.Eval.default", "EvalHom"),
    ("Types.Hom.Serve.default", "ServeHom"),
    ("Types.Hom.Main.default", "MainHom"),
    # Product (7 x Output + 7 x Meta)
    ("Types.Product.Discovery.Output.default", "DiscoveryProductOutput"),
    ("Types.Product.Discovery.Meta.default", "DiscoveryProductMeta"),
    ("Types.Product.Ingest.Output.default", "IngestProductOutput"),
    ("Types.Product.Ingest.Meta.default", "IngestProductMeta"),
    ("Types.Product.Feature.Output.default", "FeatureProductOutput"),
    ("Types.Product.Feature.Meta.default", "FeatureProductMeta"),
    ("Types.Product.Train.Output.default", "TrainProductOutput"),
    ("Types.Product.Train.Meta.default", "TrainProductMeta"),
    ("Types.Product.Eval.Output.default", "EvalProductOutput"),
    ("Types.Product.Eval.Meta.default", "EvalProductMeta"),
    ("Types.Product.Serve.Output.default", "ServeProductOutput"),
    ("Types.Product.Serve.Meta.default", "ServeProductMeta"),
    ("Types.Product.Main.Output.default", "MainProductOutput"),
    ("Types.Product.Main.Meta.default", "MainProductMeta"),
    # Monad
    ("Types.Monad.Error.default", "ErrorMonad"),
    ("Types.Monad.Metric.default", "MetricMonad"),
    ("Types.Monad.Alarm.default", "AlarmMonad"),
    ("Types.Monad.Observability.default", "ObservabilityMonad"),
    ("Types.Monad.Store.default", "StoreMonad"),
    # CoTypes — CoIdentity
    ("CoTypes.CoIdentity.Asset.default", "CoAssetIdentity"),
    ("CoTypes.CoIdentity.Run.default", "CoRunIdentity"),
    # CoTypes — CoInductive
    ("CoTypes.CoInductive.Algo.default", "CoAlgoInductive"),
    ("CoTypes.CoInductive.OHLCV.default", "CoOHLCVInductive"),
    ("CoTypes.CoInductive.Screener.default", "CoScreenerInductive"),
    ("CoTypes.CoInductive.ScreenerQuote.default", "CoScreenerQuoteInductive"),
    ("CoTypes.CoInductive.TickerInfo.default", "CoTickerInfoInductive"),
    # CoTypes — CoDependent
    ("CoTypes.CoDependent.Env.default", "CoEnvDependent"),
    ("CoTypes.CoDependent.Risk.default", "CoRiskDependent"),
    ("CoTypes.CoDependent.Liquidity.default", "CoLiquidityDependent"),
    ("CoTypes.CoDependent.Alarm.default", "CoAlarmDependent"),
    ("CoTypes.CoDependent.Optimize.default", "CoOptimizeDependent"),
    # CoTypes — CoHom (7 canonical phases)
    ("CoTypes.CoHom.Discovery.default", "CoDiscoveryHom"),
    ("CoTypes.CoHom.Ingest.default", "CoIngestHom"),
    ("CoTypes.CoHom.Feature.default", "CoFeatureHom"),
    ("CoTypes.CoHom.Train.default", "CoTrainHom"),
    ("CoTypes.CoHom.Eval.default", "CoEvalHom"),
    ("CoTypes.CoHom.Serve.default", "CoServeHom"),
    ("CoTypes.CoHom.Main.default", "CoMainHom"),
    # CoTypes — CoProduct (7 x Output + 7 x Meta)
    ("CoTypes.CoProduct.Discovery.Output.default", "CoDiscoveryProductOutput"),
    ("CoTypes.CoProduct.Discovery.Meta.default", "CoDiscoveryProductMeta"),
    ("CoTypes.CoProduct.Ingest.Output.default", "CoIngestProductOutput"),
    ("CoTypes.CoProduct.Ingest.Meta.default", "CoIngestProductMeta"),
    ("CoTypes.CoProduct.Feature.Output.default", "CoFeatureProductOutput"),
    ("CoTypes.CoProduct.Feature.Meta.default", "CoFeatureProductMeta"),
    ("CoTypes.CoProduct.Train.Output.default", "CoTrainProductOutput"),
    ("CoTypes.CoProduct.Train.Meta.default", "CoTrainProductMeta"),
    ("CoTypes.CoProduct.Eval.Output.default", "CoEvalProductOutput"),
    ("CoTypes.CoProduct.Eval.Meta.default", "CoEvalProductMeta"),
    ("CoTypes.CoProduct.Serve.Output.default", "CoServeProductOutput"),
    ("CoTypes.CoProduct.Serve.Meta.default", "CoServeProductMeta"),
    ("CoTypes.CoProduct.Main.Output.default", "CoMainProductOutput"),
    ("CoTypes.CoProduct.Main.Meta.default", "CoMainProductMeta"),
    # CoTypes — Comonad
    ("CoTypes.Comonad.Trace.default", "TraceComonad"),
]

# IO executor modules (Settings classes, not type definitions)
IO_MODULES: list[tuple[str, str]] = [
    ("Types.IO.IODiscoveryPhase.default", "Settings"),
    ("Types.IO.IOIngestPhase.default", "Settings"),
    ("Types.IO.IOFeaturePhase.default", "Settings"),
    ("Types.IO.IOTrainPhase.default", "Settings"),
    ("Types.IO.IOEvalPhase.default", "Settings"),
    ("Types.IO.IOServePhase.default", "Settings"),
    ("Types.IO.IOMainPhase.default", "Settings"),
    ("CoTypes.CoIO.CoIODiscoveryPhase.default", "Settings"),
    ("CoTypes.CoIO.CoIOIngestPhase.default", "Settings"),
    ("CoTypes.CoIO.CoIOFeaturePhase.default", "Settings"),
    ("CoTypes.CoIO.CoIOTrainPhase.default", "Settings"),
    ("CoTypes.CoIO.CoIOEvalPhase.default", "Settings"),
    ("CoTypes.CoIO.CoIOServePhase.default", "Settings"),
    ("CoTypes.CoIO.CoIOMainPhase.default", "Settings"),
]

MAX_FIELDS = 7


def _check_imports() -> tuple[bool, list[str]]:
    """Check that all type modules import without error. Returns (all_ok, errors)."""
    errors: list[str] = []
    for mod_path, cls_name in TYPE_MODULES + IO_MODULES:
        try:
            mod = importlib.import_module(mod_path)
            if not hasattr(mod, cls_name):
                errors.append(f"{mod_path} missing {cls_name}")
        except Exception as e:
            errors.append(f"{mod_path}: {str(e)[:128]}")
    return len(errors) == 0, errors


def _check_field_counts() -> tuple[bool, list[str]]:
    """Check that all BaseModel types have <=7 fields with descriptions."""
    errors: list[str] = []
    for mod_path, cls_name in TYPE_MODULES:
        try:
            mod = importlib.import_module(mod_path)
            cls = getattr(mod, cls_name, None)
            if cls is None or not (
                isinstance(cls, type) and issubclass(cls, BaseModel)
            ):
                continue
            fields = cls.model_fields
            if len(fields) > MAX_FIELDS:
                errors.append(f"{cls_name}: {len(fields)} fields (max {MAX_FIELDS})")
            for fname, finfo in fields.items():
                if not finfo.description:
                    errors.append(f"{cls_name}.{fname}: missing description")
        except Exception:
            pass  # import errors caught by _check_imports
    return len(errors) == 0, errors


def _check_json_fidelity() -> tuple[bool, list[str]]:
    """Check that default.json files match their Settings schema keys."""
    errors: list[str] = []
    json_dirs = [
        ("Types/IO", "IO"),
        ("CoTypes/CoIO", "CoIO"),
    ]
    for base_dir, prefix in json_dirs:
        base = Path(base_dir)
        if not base.exists():
            continue
        for phase_dir in sorted(base.iterdir()):
            if not phase_dir.is_dir() or phase_dir.name.startswith("_"):
                continue
            json_file = phase_dir / "default.json"
            if not json_file.exists():
                continue
            try:
                with open(json_file) as f:
                    data = json.load(f)
                # Import the Settings class and compare keys
                mod_path = str(phase_dir).replace("/", ".") + ".default"
                mod = importlib.import_module(mod_path)
                settings_cls = getattr(mod, "Settings", None)
                if settings_cls is None:
                    continue
                schema_keys = set(settings_cls.model_fields.keys())
                json_keys = set(data.keys())
                if json_keys != schema_keys:
                    missing = schema_keys - json_keys
                    extra = json_keys - schema_keys
                    if missing:
                        errors.append(f"{json_file}: missing keys {missing}")
                    if extra:
                        errors.append(f"{json_file}: extra keys {extra}")
            except Exception as e:
                errors.append(f"{json_file}: {str(e)[:128]}")
    return len(errors) == 0, errors


def run(cfg: CoMainHom, store: StoreMonad) -> CoMainProductOutput:
    """Observe the main pipeline artifact + validate type system + optionally visualize."""
    observer_id = uuid.uuid4().hex[:8]
    now = datetime.now(timezone.utc).isoformat()
    meta = CoMainProductMeta(
        trace=TraceComonad(
            observer_id=observer_id,
            cursor="",
            events_seen=0,
            connection_ok=True,
            last_seen_at=now,
        ),
        artifact_found=False,
        schema_valid=False,
    )

    pipeline_completed = False
    windows_evaluated = False
    result_persisted = False
    validate_passed = True
    visualize_logged = False

    # ── (a) Probe StoreMonad for the latest main artifact ──────────
    try:
        row = store.latest(PhaseId.pipeline.value, "main")
        meta.artifact_found = True
        meta.trace.events_seen = 1
        meta.trace.cursor = row.blob_path
    except KeyError:
        meta.artifact_found = False

    if meta.artifact_found:
        pipeline_completed = True
        result_persisted = True
        try:
            md = json.loads(row.metadata_json)
            meta.schema_valid = True
            n_windows = md.get("n_windows", 0)
            windows_evaluated = isinstance(n_windows, (int, float)) and n_windows > 0
        except (json.JSONDecodeError, TypeError):
            meta.schema_valid = False

    # ── (b) Type system validation (flattened from CoIOValidatePhase) ──
    if cfg.validate_imports:
        ok, _errors = _check_imports()
        meta.imports_healthy = ok
        if not ok:
            validate_passed = False

    if cfg.validate_fields:
        ok, _errors = _check_field_counts()
        meta.field_counts_valid = ok
        if not ok:
            validate_passed = False

    if cfg.validate_json:
        ok, _errors = _check_json_fidelity()
        meta.json_fidelity = ok
        if not ok:
            validate_passed = False

    # ── (c) Cross-phase Rerun visualization (flattened from IOVisualizePhase) ──
    if cfg.visualize:
        try:
            import rerun as rr

            all_rows = store.all_runs()
            phases_seen: set[str] = set()
            for artifact_row in all_rows:
                phases_seen.add(artifact_row.phase)

            rr.init("rl-lab-observer", spawn=False)
            for phase_name in sorted(phases_seen):
                phase_rows = [r for r in all_rows if r.phase == phase_name]
                for r in phase_rows:
                    try:
                        md = json.loads(r.metadata_json)
                        for k, v in md.items():
                            if isinstance(v, (int, float)):
                                rr.log(f"{phase_name}/{k}", rr.Scalar(v))
                    except (json.JSONDecodeError, TypeError):
                        pass

            meta.n_phases_visualized = len(phases_seen)
            visualize_logged = len(phases_seen) > 0
        except ImportError:
            meta.n_phases_visualized = 0
            visualize_logged = False

    return CoMainProductOutput(
        observer_id=observer_id,
        pipeline_completed=pipeline_completed,
        windows_evaluated=windows_evaluated,
        result_persisted=result_persisted,
        validate_passed=validate_passed,
        visualize_logged=visualize_logged,
        meta=meta,
    )


class Settings(BaseSettings):
    """CoIOMainPhase Settings — Main observer entrypoint."""

    model_config = SettingsConfigDict(
        json_file="CoTypes/CoIO/CoIOMainPhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="ana-main",
    )
    main: CoMainHom = Field(
        default_factory=CoMainHom,
        description="Main observer config — artifact probe + validation + visualization",
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
    s = Settings()
    result = run(s.main, s.store)
    print(result.model_dump_json(indent=2))
