"""CoIOComposePhase [CoIO] — Main phase observation executor.

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

from CoTypes.CoHom.Compose.default import CoComposeHom
from CoTypes.CoProduct.Compose.Output.default import CoComposeProductOutput
from CoTypes.CoProduct.Compose.Meta.default import CoComposeProductMeta
from CoTypes.Comonad.Trace.default import TraceComonad, CoPhaseId
from Types.Monad.Store.default import StoreMonad
from Types.Monad.Error.default import PhaseId


# ── Type module registry for import health checks ──────────────────
TYPE_MODULES: list[tuple[str, str]] = [
    # Identity
    ("Types.Identity.Index.default", "IndexIdentity"),
    ("Types.Identity.Session.default", "SessionIdentity"),
    # Inductive
    ("Types.Inductive.Solver.default", "SolverInductive"),
    ("Types.Inductive.Frame.default", "FrameInductive"),
    ("Types.Inductive.Catalog.default", "CatalogInductive"),
    ("Types.Inductive.CatalogEntry.default", "CatalogEntryInductive"),
    ("Types.Inductive.IndexMeta.default", "IndexMetaInductive"),
    # Dependent
    ("Types.Dependent.Execution.default", "ExecutionDependent"),
    ("Types.Dependent.Constraint.default", "ConstraintDependent"),
    ("Types.Dependent.Filter.default", "FilterDependent"),
    ("Types.Dependent.Threshold.default", "ThresholdDependent"),
    ("Types.Dependent.Search.default", "SearchDependent"),
    # Hom (7 canonical phases only)
    ("Types.Hom.Discovery.default", "DiscoveryHom"),
    ("Types.Hom.Ingest.default", "IngestHom"),
    ("Types.Hom.Transform.default", "TransformHom"),
    ("Types.Hom.Solve.default", "SolveHom"),
    ("Types.Hom.Eval.default", "EvalHom"),
    ("Types.Hom.Project.default", "ProjectHom"),
    ("Types.Hom.Compose.default", "ComposeHom"),
    # Product (7 x Output + 7 x Meta)
    ("Types.Product.Discovery.Output.default", "DiscoveryProductOutput"),
    ("Types.Product.Discovery.Meta.default", "DiscoveryProductMeta"),
    ("Types.Product.Ingest.Output.default", "IngestProductOutput"),
    ("Types.Product.Ingest.Meta.default", "IngestProductMeta"),
    ("Types.Product.Transform.Output.default", "TransformProductOutput"),
    ("Types.Product.Transform.Meta.default", "TransformProductMeta"),
    ("Types.Product.Solve.Output.default", "SolveProductOutput"),
    ("Types.Product.Solve.Meta.default", "SolveProductMeta"),
    ("Types.Product.Eval.Output.default", "EvalProductOutput"),
    ("Types.Product.Eval.Meta.default", "EvalProductMeta"),
    ("Types.Product.Project.Output.default", "ProjectProductOutput"),
    ("Types.Product.Project.Meta.default", "ProjectProductMeta"),
    ("Types.Product.Compose.Output.default", "ComposeProductOutput"),
    ("Types.Product.Compose.Meta.default", "ComposeProductMeta"),
    # Monad
    ("Types.Monad.Error.default", "ErrorMonad"),
    ("Types.Monad.Measure.default", "MeasureMonad"),
    ("Types.Monad.Signal.default", "SignalMonad"),
    ("Types.Monad.Effect.default", "EffectMonad"),
    ("Types.Monad.Store.default", "StoreMonad"),
    # CoTypes — CoIdentity
    ("CoTypes.CoIdentity.Index.default", "CoIndexIdentity"),
    ("CoTypes.CoIdentity.Session.default", "CoSessionIdentity"),
    # CoTypes — CoInductive
    ("CoTypes.CoInductive.Solver.default", "CoSolverInductive"),
    ("CoTypes.CoInductive.Frame.default", "CoFrameInductive"),
    ("CoTypes.CoInductive.Catalog.default", "CoCatalogInductive"),
    ("CoTypes.CoInductive.CatalogEntry.default", "CoCatalogEntryInductive"),
    ("CoTypes.CoInductive.IndexMeta.default", "CoIndexMetaInductive"),
    # CoTypes — CoDependent
    ("CoTypes.CoDependent.Execution.default", "CoExecutionDependent"),
    ("CoTypes.CoDependent.Constraint.default", "CoConstraintDependent"),
    ("CoTypes.CoDependent.Filter.default", "CoFilterDependent"),
    ("CoTypes.CoDependent.Threshold.default", "CoThresholdDependent"),
    ("CoTypes.CoDependent.Search.default", "CoSearchDependent"),
    # CoTypes — CoHom (7 canonical phases)
    ("CoTypes.CoHom.Discovery.default", "CoDiscoveryHom"),
    ("CoTypes.CoHom.Ingest.default", "CoIngestHom"),
    ("CoTypes.CoHom.Transform.default", "CoTransformHom"),
    ("CoTypes.CoHom.Solve.default", "CoSolveHom"),
    ("CoTypes.CoHom.Eval.default", "CoEvalHom"),
    ("CoTypes.CoHom.Project.default", "CoProjectHom"),
    ("CoTypes.CoHom.Compose.default", "CoComposeHom"),
    # CoTypes — CoProduct (7 x Output + 7 x Meta)
    ("CoTypes.CoProduct.Discovery.Output.default", "CoDiscoveryProductOutput"),
    ("CoTypes.CoProduct.Discovery.Meta.default", "CoDiscoveryProductMeta"),
    ("CoTypes.CoProduct.Ingest.Output.default", "CoIngestProductOutput"),
    ("CoTypes.CoProduct.Ingest.Meta.default", "CoIngestProductMeta"),
    ("CoTypes.CoProduct.Transform.Output.default", "CoTransformProductOutput"),
    ("CoTypes.CoProduct.Transform.Meta.default", "CoTransformProductMeta"),
    ("CoTypes.CoProduct.Solve.Output.default", "CoSolveProductOutput"),
    ("CoTypes.CoProduct.Solve.Meta.default", "CoSolveProductMeta"),
    ("CoTypes.CoProduct.Eval.Output.default", "CoEvalProductOutput"),
    ("CoTypes.CoProduct.Eval.Meta.default", "CoEvalProductMeta"),
    ("CoTypes.CoProduct.Project.Output.default", "CoProjectProductOutput"),
    ("CoTypes.CoProduct.Project.Meta.default", "CoProjectProductMeta"),
    ("CoTypes.CoProduct.Compose.Output.default", "CoComposeProductOutput"),
    ("CoTypes.CoProduct.Compose.Meta.default", "CoComposeProductMeta"),
    # CoTypes — Comonad
    ("CoTypes.Comonad.Trace.default", "TraceComonad"),
]

# IO executor modules (Settings classes, not type definitions)
IO_MODULES: list[tuple[str, str]] = [
    ("Types.IO.IODiscoveryPhase.default", "Settings"),
    ("Types.IO.IOIngestPhase.default", "Settings"),
    ("Types.IO.IOTransformPhase.default", "Settings"),
    ("Types.IO.IOSolvePhase.default", "Settings"),
    ("Types.IO.IOEvalPhase.default", "Settings"),
    ("Types.IO.IOProjectPhase.default", "Settings"),
    ("Types.IO.IOComposePhase.default", "Settings"),
    ("CoTypes.CoIO.CoIODiscoveryPhase.default", "Settings"),
    ("CoTypes.CoIO.CoIOIngestPhase.default", "Settings"),
    ("CoTypes.CoIO.CoIOTransformPhase.default", "Settings"),
    ("CoTypes.CoIO.CoIOSolvePhase.default", "Settings"),
    ("CoTypes.CoIO.CoIOEvalPhase.default", "Settings"),
    ("CoTypes.CoIO.CoIOProjectPhase.default", "Settings"),
    ("CoTypes.CoIO.CoIOComposePhase.default", "Settings"),
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
        except Exception as e:  # noqa: F841 — import errors caught by _check_imports
            pass
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


def _check_roundtrip_closure() -> tuple[bool, list[str]]:
    """Path (a): verify fromJson(toJson(Hom)) == Hom for all Hom types.

    True roundtrip closure — serializes each Hom type to JSON and deserializes
    back, asserting field-level identity. This is the unit η of the
    free-forgetful adjunction: toJson is the unit, fromJson is the counit.
    """
    errors: list[str] = []
    hom_modules = [
        ("Types.Hom.Discovery.default", "DiscoveryHom"),
        ("Types.Hom.Ingest.default", "IngestHom"),
        ("Types.Hom.Transform.default", "TransformHom"),
        ("Types.Hom.Solve.default", "SolveHom"),
        ("Types.Hom.Eval.default", "EvalHom"),
        ("Types.Hom.Project.default", "ProjectHom"),
        ("Types.Hom.Compose.default", "ComposeHom"),
    ]
    for mod_path, cls_name in hom_modules:
        try:
            mod = importlib.import_module(mod_path)
            cls = getattr(mod, cls_name)
            # Construct default instance
            original = cls()
            # Roundtrip: serialize -> deserialize
            json_str = original.model_dump_json()
            restored = cls.model_validate_json(json_str)
            # Field-level identity check
            if original.model_dump() != restored.model_dump():
                errors.append(f"{cls_name}: roundtrip mismatch")
        except Exception as e:
            errors.append(f"{cls_name}: {str(e)[:128]}")
    return len(errors) == 0, errors


def run(cfg: CoComposeHom, store: StoreMonad) -> CoComposeProductOutput:
    """Observe the main pipeline artifact + validate type system + optionally visualize."""
    observer_id = uuid.uuid4().hex[:8]
    now = datetime.now(timezone.utc).isoformat()
    meta = CoComposeProductMeta(
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
        row = store.latest(PhaseId.compose.value, "main")
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
        rt_ok, _rt_errors = _check_roundtrip_closure()
        meta.json_fidelity = ok and rt_ok
        if not ok or not rt_ok:
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

    return CoComposeProductOutput(
        observer_id=observer_id,
        pipeline_completed=pipeline_completed,
        windows_evaluated=windows_evaluated,
        result_persisted=result_persisted,
        validate_passed=validate_passed,
        visualize_logged=visualize_logged,
        meta=meta,
    )


class Settings(BaseSettings):
    """CoIOComposePhase Settings — Main observer entrypoint."""

    model_config = SettingsConfigDict(
        json_file="CoTypes/CoIO/CoIOComposePhase/default.json",
        json_file_encoding="utf-8",
        cli_parse_args=True,
        cli_prog_name="ana-main",
    )
    compose: CoComposeHom = Field(
        default_factory=CoComposeHom,
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
        from pathlib import Path as _P

        sources = [CliSettingsSource(settings_cls, cli_parse_args=True)]
        _local = _P(__file__).parent / "local.json"
        if _local.exists():
            sources.append(JsonConfigSettingsSource(settings_cls, json_file=_local))
        sources.append(JsonConfigSettingsSource(settings_cls))
        return tuple(sources)


if __name__ == "__main__":
    s = Settings()
    result = run(s.main, s.store)
    print(result.model_dump_json(indent=2))
