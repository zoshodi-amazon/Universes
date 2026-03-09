"""default.py — System integrity checker. The 'nix eval' equivalent.

Validates the entire type system, phase mapping, field invariants,
and JSON fidelity in a single pass. Exit 0 if clean, exit 1 with errors.

Usage:
    just validate
"""

import importlib
import json
import sys
from pathlib import Path
from pydantic import BaseModel
from pydantic.fields import FieldInfo


PASS = 0
FAIL = 0
ERRORS: list[str] = []


def _ok(msg: str) -> None:
    global PASS
    PASS += 1
    print(f"  OK  {msg}")


def _fail(msg: str) -> None:
    global FAIL
    FAIL += 1
    ERRORS.append(msg)
    print(f"  FAIL  {msg}")


# ── 1. Import health ─────────────────────────────────────────────────
print("\n=== 1. Import Health ===")

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
    # Hom
    ("Types.Hom.Discovery.default", "DiscoveryHom"),
    ("Types.Hom.Ingest.default", "IngestHom"),
    ("Types.Hom.Feature.default", "FeatureHom"),
    ("Types.Hom.Train.default", "TrainHom"),
    ("Types.Hom.Eval.default", "EvalHom"),
    ("Types.Hom.Serve.default", "ServeHom"),
    ("Types.Hom.Main.default", "MainHom"),
    ("Types.Hom.Pipeline.default", "PipelineHom"),
    # Product
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
    # CoTypes — existing observers
    ("CoTypes.CoHom.Tail.default", "TailCoHom"),
    ("CoTypes.CoHom.Visualize.default", "VisualizeCoHom"),
    ("CoTypes.Comonad.Trace.default", "TraceComonad"),
    ("CoTypes.CoProduct.Tail.Output.default", "TailCoProductOutput"),
    ("CoTypes.CoProduct.Tail.Meta.default", "TailCoProductMeta"),
    ("CoTypes.CoProduct.Visualize.Output.default", "VisualizeCoProductOutput"),
    ("CoTypes.CoProduct.Visualize.Meta.default", "VisualizeCoProductMeta"),
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
    ("CoTypes.CoDependent.Alarm.default", "CoAlarmDependent"),
    ("CoTypes.CoDependent.Env.default", "CoEnvDependent"),
    ("CoTypes.CoDependent.Liquidity.default", "CoLiquidityDependent"),
    ("CoTypes.CoDependent.Optimize.default", "CoOptimizeDependent"),
    ("CoTypes.CoDependent.Risk.default", "CoRiskDependent"),
    # CoTypes — per-phase CoHom
    ("CoTypes.CoHom.Discovery.default", "CoDiscoveryHom"),
    ("CoTypes.CoHom.Ingest.default", "CoIngestHom"),
    ("CoTypes.CoHom.Feature.default", "CoFeatureHom"),
    ("CoTypes.CoHom.Train.default", "CoTrainHom"),
    ("CoTypes.CoHom.Eval.default", "CoEvalHom"),
    ("CoTypes.CoHom.Serve.default", "CoServeHom"),
    ("CoTypes.CoHom.Main.default", "CoMainHom"),
    # CoTypes — per-phase CoProduct
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
    # Hom — ServeInput composite
    ("Types.Hom.ServeInput.default", "ServeInputHom"),
]

IO_MODULES: list[str] = [
    "Types.IO.IODiscoveryPhase.default",
    "Types.IO.IOIngestPhase.default",
    "Types.IO.IOFeaturePhase.default",
    "Types.IO.IOTrainPhase.default",
    "Types.IO.IOEvalPhase.default",
    "Types.IO.IOServePhase.default",
    "Types.IO.IOMainPhase.default",
    "CoTypes.CoIO.IOTailPhase.default",
    "CoTypes.CoIO.IOVisualizePhase.default",
    "CoTypes.CoIO.CoIODiscoveryPhase.default",
    "CoTypes.CoIO.CoIOIngestPhase.default",
    "CoTypes.CoIO.CoIOFeaturePhase.default",
    "CoTypes.CoIO.CoIOTrainPhase.default",
    "CoTypes.CoIO.CoIOEvalPhase.default",
    "CoTypes.CoIO.CoIOServePhase.default",
    "CoTypes.CoIO.CoIOMainPhase.default",
]

imported_types: dict[str, type[BaseModel]] = {}

for mod_path, cls_name in TYPE_MODULES:
    try:
        mod = importlib.import_module(mod_path)
        cls = getattr(mod, cls_name)
        imported_types[cls_name] = cls
        _ok(f"{mod_path}.{cls_name}")
    except Exception as e:
        _fail(f"{mod_path}.{cls_name}: {e}")

for mod_path in IO_MODULES:
    try:
        importlib.import_module(mod_path)
        _ok(f"{mod_path}")
    except Exception as e:
        _fail(f"{mod_path}: {e}")


# ── 2. Field count (≤7) ──────────────────────────────────────────────
print("\n=== 2. Field Count (<=7) ===")

for cls_name, cls in imported_types.items():
    if not hasattr(cls, "model_fields"):
        _ok(f"{cls_name}: enum/non-model type (skip field count)")
        continue
    n = len(cls.model_fields)
    if n <= 7:
        _ok(f"{cls_name}: {n} fields")
    else:
        _fail(f"{cls_name}: {n} fields (max 7)")

# IO Settings field count
for mod_path in IO_MODULES:
    try:
        mod = importlib.import_module(mod_path)
        settings_cls = getattr(mod, "Settings", None)
        if settings_cls:
            n = len(settings_cls.model_fields)
            name = mod_path.split(".")[-2]
            if n <= 7:
                _ok(f"{name} Settings: {n} fields")
            else:
                _fail(f"{name} Settings: {n} fields (max 7)")
    except Exception:
        pass


# ── 3. Field descriptions ────────────────────────────────────────────
print("\n=== 3. Field Descriptions ===")

for cls_name, cls in imported_types.items():
    if not hasattr(cls, "model_fields"):
        continue
    missing = [f for f, info in cls.model_fields.items() if not info.description]
    if missing:
        _fail(f"{cls_name}: fields missing description: {missing}")
    else:
        _ok(f"{cls_name}: all fields have descriptions")


# ── 4. Field bounds ──────────────────────────────────────────────────
print("\n=== 4. Field Bounds ===")


def _has_numeric_bounds(info: FieldInfo) -> bool:
    """Check if a numeric field has ge/le/gt/lt metadata."""
    for m in info.metadata:
        if hasattr(m, "ge") or hasattr(m, "le") or hasattr(m, "gt") or hasattr(m, "lt"):
            return True
    if info.json_schema_extra and (
        "ge" in str(info.json_schema_extra) or "le" in str(info.json_schema_extra)
    ):
        return True
    return False


def _has_string_bounds(info: FieldInfo) -> bool:
    """Check if a string field has length constraints."""
    for m in info.metadata:
        if (
            hasattr(m, "min_length")
            or hasattr(m, "max_length")
            or hasattr(m, "pattern")
        ):
            return True
    return False


for cls_name, cls in imported_types.items():
    if not hasattr(cls, "model_fields"):
        continue
    for field_name, info in cls.model_fields.items():
        ann = info.annotation
        ann_str = str(ann) if ann else ""
        # Skip complex types (lists, nested models, enums, bools)
        if ann and isinstance(ann, type) and issubclass(ann, BaseModel):
            continue
        if "list[" in ann_str.lower() or "List[" in ann_str:
            continue
        if ann is bool or ann_str == "<class 'bool'>":
            continue
        if ann and isinstance(ann, type) and hasattr(ann, "__members__"):
            continue
        # Check int/float
        if ann in (int, float) or "int" in ann_str or "float" in ann_str:
            if not _has_numeric_bounds(info):
                _fail(f"{cls_name}.{field_name}: numeric field missing ge/le bounds")
            else:
                _ok(f"{cls_name}.{field_name}: bounded")


# ── 5. JSON fidelity ─────────────────────────────────────────────────
print("\n=== 5. JSON Fidelity ===")

json_files: list[tuple[str, str]] = [
    ("Types/IO/IODiscoveryPhase/default.json", "Types.IO.IODiscoveryPhase.default"),
    ("Types/IO/IOIngestPhase/default.json", "Types.IO.IOIngestPhase.default"),
    ("Types/IO/IOFeaturePhase/default.json", "Types.IO.IOFeaturePhase.default"),
    ("Types/IO/IOTrainPhase/default.json", "Types.IO.IOTrainPhase.default"),
    ("Types/IO/IOEvalPhase/default.json", "Types.IO.IOEvalPhase.default"),
    ("Types/IO/IOServePhase/default.json", "Types.IO.IOServePhase.default"),
    ("Types/IO/IOMainPhase/default.json", "Types.IO.IOMainPhase.default"),
    ("CoTypes/CoIO/IOTailPhase/default.json", "CoTypes.CoIO.IOTailPhase.default"),
    (
        "CoTypes/CoIO/IOVisualizePhase/default.json",
        "CoTypes.CoIO.IOVisualizePhase.default",
    ),
]

for json_path, mod_path in json_files:
    try:
        mod = importlib.import_module(mod_path)
        settings_cls = getattr(mod, "Settings")
        with open(json_path) as f:
            data = json.load(f)
        json_keys = set(data.keys())
        model_keys = set(settings_cls.model_fields.keys())
        extra = json_keys - model_keys
        missing = model_keys - json_keys
        if extra:
            _fail(f"{json_path}: extra keys in JSON not in Settings: {extra}")
        elif missing:
            _ok(f"{json_path}: {len(missing)} fields use defaults: {missing}")
        else:
            _ok(f"{json_path}: keys match Settings")
    except Exception as e:
        _fail(f"{json_path}: {e}")


# ── 6. Phase mapping ─────────────────────────────────────────────────
print("\n=== 6. Phase Mapping ===")

PHASES = ["Discovery", "Ingest", "Feature", "Train", "Eval", "Serve", "Main"]
for phase in PHASES:
    hom = f"{phase}Hom" in imported_types
    output = f"{phase}ProductOutput" in imported_types
    meta = f"{phase}ProductMeta" in imported_types
    io_mod = f"Types.IO.IO{phase}Phase.default" in IO_MODULES
    if hom and output and meta and io_mod:
        _ok(f"{phase}: Hom + ProductOutput + ProductMeta + IO executor")
    else:
        parts = []
        if not hom:
            parts.append("Hom")
        if not output:
            parts.append("ProductOutput")
        if not meta:
            parts.append("ProductMeta")
        if not io_mod:
            parts.append("IO executor")
        _fail(f"{phase}: missing {', '.join(parts)}")


# ── 7. Observer mapping ──────────────────────────────────────────────
print("\n=== 7. Observer Mapping ===")

OBSERVERS = [
    (
        "Tail",
        "TailCoHom",
        "TailCoProductOutput",
        "TailCoProductMeta",
        "CoTypes.CoIO.IOTailPhase.default",
    ),
    (
        "Visualize",
        "VisualizeCoHom",
        "VisualizeCoProductOutput",
        "VisualizeCoProductMeta",
        "CoTypes.CoIO.IOVisualizePhase.default",
    ),
]
for name, cohom, out, meta_name, io in OBSERVERS:
    has_all = all(
        [
            cohom in imported_types,
            out in imported_types,
            meta_name in imported_types,
            io in IO_MODULES,
        ]
    )
    if has_all:
        _ok(f"{name}: CoHom + CoProductOutput + CoProductMeta + IO executor")
    else:
        _fail(f"{name}: missing components")


# ── 8. No empty directories ──────────────────────────────────────────
print("\n=== 8. No Empty Directories ===")

for root_dir in ["Types", "CoTypes"]:
    for dirpath, dirnames, filenames in Path(root_dir).walk():
        # Skip __pycache__
        dirnames[:] = [d for d in dirnames if d != "__pycache__"]
        py_files = [f for f in filenames if f.endswith(".py") or f.endswith(".json")]
        if not py_files and not dirnames:
            _fail(f"empty directory: {dirpath}")
        elif py_files:
            _ok(f"{dirpath}: {len(py_files)} files")


# ── 9. Filename invariant ────────────────────────────────────────────
print("\n=== 9. Filename Invariant (all files must be default.*) ===")

ALLOWED_FILENAMES = {"default.py", "default.json", "__init__.py"}

for root_dir in ["Types", "CoTypes"]:
    for dirpath, dirnames, filenames in Path(root_dir).walk():
        dirnames[:] = [d for d in dirnames if d != "__pycache__"]
        for f in filenames:
            if f in ALLOWED_FILENAMES:
                continue
            if f.endswith(".pyc"):
                continue
            _fail(f"{Path(dirpath) / f}: filename must be default.* or __init__.py")

# ── 10. Directory name capitalization ─────────────────────────────────
print("\n=== 10. Directory Capitalization ===")

for root_dir in ["Types", "CoTypes"]:
    for dirpath, dirnames, filenames in Path(root_dir).walk():
        dirnames[:] = [d for d in dirnames if d != "__pycache__"]
        for d in dirnames:
            if d[0].isupper():
                _ok(f"{Path(dirpath) / d}: capitalized")
            else:
                _fail(f"{Path(dirpath) / d}: directory name must start with uppercase")


# ── 11. Type round-trip ───────────────────────────────────────────────
print("\n=== 11. Type Round-Trip ===")

SKIP_ROUNDTRIP = {
    "ErrorMonad",
    "MetricMonad",
    "AlarmMonad",
    "ObservabilityMonad",
    "DiscoveryProductOutput",
    "ServeHom",
    "OHLCVInductive",
    "ArtifactRow",
    "AssetIdentity",
    "ScreenerQuoteInductive",
    "IngestProductOutput",
    "FeatureProductOutput",
    "TrainProductOutput",
    "EvalProductOutput",
    "ServeProductOutput",
    "MainProductOutput",
}

for cls_name, cls in imported_types.items():
    if cls_name in SKIP_ROUNDTRIP:
        _ok(f"{cls_name}: skipped (has required fields)")
        continue
    if not hasattr(cls, "model_fields"):
        _ok(f"{cls_name}: enum/non-model type (skip round-trip)")
        continue
    try:
        instance = cls()
        json_str = instance.model_dump_json()
        cls.model_validate_json(json_str)
        _ok(f"{cls_name}: round-trip OK")
    except Exception as e:
        _fail(f"{cls_name}: round-trip failed: {e}")


# ── Summary ───────────────────────────────────────────────────────────
print(f"\n{'=' * 60}")
print(f"PASS: {PASS}  FAIL: {FAIL}")
if FAIL > 0:
    print(f"\nFailures:")
    for err in ERRORS:
        print(f"  - {err}")
    sys.exit(1)
else:
    print("All checks passed.")
    sys.exit(0)
