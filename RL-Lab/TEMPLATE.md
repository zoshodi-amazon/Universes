# TEMPLATE.md — RL-Lab

Lab-specific naming, structural templates, and conventions for the RL-Lab. Extends `Universes/TEMPLATE.md`.

---

## 1. Base Point

| Field | Value |
|-------|-------|
| Lab name | `RL-Lab` |
| Artifact type | Autonomous quant RL pipeline (single-asset) |
| Type language | **Lean 4** (canonical, strata 1-6) -- currently provisional Python |
| IO runtime | Python (pydantic + stable-baselines3 + gymnasium) |

---

## 2. Phase Chain (FROZEN)

```
Discovery -> Ingest -> Feature -> Train -> Eval -> Serve -> Main
```

| # | Phase | Matter | Type Theory | IO Executor | Intuition |
|---|-------|--------|-------------|-------------|-----------|
| 1 | Discovery | BEC | Unit (top) | IODiscoveryPhase | "What universe exists?" |
| 2 | Ingest | Crystalline | Inductive (ADT) | IOIngestPhase | "What data structure?" |
| 3 | Feature | Liquid Crystal | Dependent type | IOFeaturePhase | "What geometry?" |
| 4 | Train | Liquid | Function (A -> B) | IOTrainPhase | "What transformation?" |
| 5 | Eval | Gas | Product/Sum | IOEvalPhase | "What outcomes?" |
| 6 | Serve | Plasma | Monad (M A) | IOServePhase | "What effects?" |
| 7 | Main | QGP | IO | IOMainPhase | "Deploy everything" |

**Naming rule:** Phase names are PascalCase in directories (`Types/Hom/Discovery/`), lowercase in justfile commands (`cata-discover`).

---

## 3. Type Naming Conventions

### Types/ (Algebraic)

| Category | Pattern | Examples |
|----------|---------|---------|
| Identity | `{Domain}Identity` | `AssetIdentity`, `RunIdentity` |
| Inductive | `{Domain}Inductive` or `{Domain}Identity` (legacy) | `OHLCVInductive`, `ScreenerInductive`, `AlgoIdentity`, `AlarmSeverity`, `MetricKind` |
| Dependent | `{Domain}Dependent` | `EnvDependent`, `RiskDependent`, `LiquidityDependent`, `AlarmDependent`, `OptimizeDependent` |
| Hom | `{Phase}Hom` | `DiscoveryHom`, `IngestHom`, `FeatureHom`, `TrainHom`, `EvalHom`, `ServeHom`, `MainHom` |
| Product Output | `{Phase}ProductOutput` | `DiscoveryProductOutput`, `TrainProductOutput` |
| Product Meta | `{Phase}ProductMeta` | `DiscoveryProductMeta`, `TrainProductMeta` |
| Monad | `{Domain}Monad` | `ErrorMonad`, `MetricMonad`, `AlarmMonad`, `ObservabilityMonad`, `StoreMonad`, `ArtifactRow` |

### CoTypes/ (Coalgebraic)

| CoCategory | Pattern | Examples |
|------------|---------|---------|
| CoIdentity | `Co{Domain}Identity` | `CoAssetIdentity`, `CoRunIdentity` |
| CoInductive | `Co{Domain}Inductive` | `CoOHLCVInductive`, `CoScreenerInductive`, `CoAlgoInductive` |
| CoDependent | `Co{Domain}Dependent` | `CoEnvDependent`, `CoRiskDependent`, `CoLiquidityDependent` |
| CoHom | `Co{Phase}Hom` | `CoDiscoveryHom`, `CoTrainHom`, `CoMainHom` |
| CoProduct Output | `Co{Phase}ProductOutput` | `CoDiscoveryProductOutput`, `CoTrainProductOutput` |
| CoProduct Meta | `Co{Phase}ProductMeta` | `CoDiscoveryProductMeta`, `CoTrainProductMeta` |
| Comonad | `{Domain}Comonad` or `Co{Domain}Comonad` | `TraceComonad`, `CoErrorComonad`, `CoStoreComonad` |

### Naming Deviation

`AlgoIdentity` lives in `Types/Inductive/` despite the `Identity` suffix. The name reflects domain semantics (algorithm identity), but its type-theoretic category is Inductive (4-variant enum). This is a known legacy naming deviation -- the type IS an Inductive ADT, not a terminal object.

---

## 4. Python Realization

All types are `pydantic.BaseModel` subclasses. IO executors use `pydantic_settings.BaseSettings` with JSON + CLI sources.

### Type Pattern (strata 1-5)

```python
"""TypeName [Category] -- Description (N fields). All bounded."""
from pydantic import BaseModel, Field

class TypeName(BaseModel):
    """TypeName [Category] -- Description (N fields)."""
    field_name: type = Field(
        default=...,
        ge=..., le=...,           # numeric bounds (Dependent)
        min_length=..., max_length=...,  # string bounds
        description="...",        # mandatory
    )
```

### IO Executor Pattern (stratum 7)

```python
"""IO{Phase}Phase [IO] -- Description."""
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    """IO{Phase}Phase Settings (<=7 fields)."""
    {phase}: {Phase}Hom = {Phase}Hom()
    store: StoreMonad = StoreMonad()
    # ... (<=7 fields total)

    model_config = SettingsConfigDict(
        json_file="Types/IO/IO{Phase}Phase/default.json",
        cli_parse_args=True,
        cli_prefix="{phase}",
    )

def run(cfg: {Phase}Hom, store: StoreMonad) -> {Phase}ProductOutput:
    """The profunctor arrow: Hom -> Product via IO."""
    ...

if __name__ == "__main__":
    settings = Settings()
    result = run(settings.{phase}, settings.store)
```

### Observer Pattern (CoTypes/CoIO/)

```python
"""CoIO{Phase}Phase [CoIO] -- Description."""

class Settings(BaseSettings):
    """CoIO{Phase}Phase Settings (<=7 fields)."""
    {phase}: Co{Phase}Hom = Co{Phase}Hom()  # what to check
    store: StoreMonad = StoreMonad()         # where to probe

def run(cfg: Co{Phase}Hom, store: StoreMonad) -> Co{Phase}ProductOutput:
    """The observation comorphism: CoHom -> CoProduct via CoIO."""
    ...
```

---

## 5. File Extensions

### Universal (per root TEMPLATE.md)

| Extension | Category | Usage |
|-----------|----------|-------|
| `default.py` | Any (by directory) | Type definitions, IO executors, observers |
| `default.json` | IO boundary | Serialized Hom at IO boundary |
| `__init__.py` | Module init | Python package marker (empty) |

### Domain-Specific

| Extension | Category | Usage |
|-----------|----------|-------|
| `.pkl` | Product (blob) | Pickled DataFrames (ingest, feature), VecNormalize stats |
| `.zip` | Product (blob) | SB3 model archives (model.zip) |
| `.jsonl` | Product (blob) | Audit trail (one JSON object per line) |
| `.db` | Identity (store) | SQLite artifact database (`store/.rl.db`) |

---

## 6. Justfile Command Surface

15 commands: 6 cata- (production) + 7 ana-{phase} (observation) + 1 ana-check (cross-cutting) + 1 hylo-main (composite).

| Prefix | Count | Pattern | Example |
|--------|:-----:|---------|---------|
| `cata-` | 6 | `cata-{phase}` | `cata-discover`, `cata-train` |
| `ana-` | 7 | `ana-{phase}` | `ana-discover`, `ana-main` |
| `ana-` | 1 | `ana-check` (cross-cutting) | `ana-check` |
| `hylo-` | 1 | `hylo-main` | `hylo-main` |

### Dissolved Commands (no longer in justfile)

| Former Command | Absorbed Into | Activation |
|---------------|---------------|-----------|
| `ana-tail` | `ana-main` | Default (CoIOMainPhase) |
| `ana-visualize` | `ana-main` | `--main.visualize true` |
| `ana-render` | `ana-eval` | `--eval.launch_renderer true` |
| `ana-validate` | `ana-main` / `ana-check` | `--main.validate_imports true --main.validate_fields true --main.validate_json true` |

---

## 7. Profunctor Triad (per phase)

Every phase follows the universal profunctor pattern:

### Production (Types/)

```
Types/Hom/{Phase}/default.py             -- Domain: {Phase}Hom
Types/IO/IO{Phase}Phase/default.json     -- Serialized Hom (IO boundary)
Types/IO/IO{Phase}Phase/default.py       -- Arrow: run(Hom, Store) -> ProductOutput
Types/Product/{Phase}/Output/default.py  -- Codomain output: {Phase}ProductOutput
Types/Product/{Phase}/Meta/default.py    -- Codomain meta: {Phase}ProductMeta
```

### Observation (CoTypes/)

```
CoTypes/CoHom/{Phase}/default.py                    -- Spec: Co{Phase}Hom (what to check)
CoTypes/CoIO/CoIO{Phase}Phase/default.json          -- Serialized CoHom (IO boundary)
CoTypes/CoIO/CoIO{Phase}Phase/default.py            -- Probe: run(CoHom, Store) -> CoProductOutput
CoTypes/CoProduct/{Phase}/Output/default.py         -- Result: Co{Phase}ProductOutput
CoTypes/CoProduct/{Phase}/Meta/default.py           -- Trace: Co{Phase}ProductMeta
```

---

## 8. Directory Counts

| Category | Types/ | CoTypes/ | Limit |
|----------|:------:|:--------:|:-----:|
| Identity | 2 | 2 | 7 |
| Inductive | 7 | 5 | 7 |
| Dependent | 5 | 5 | 7 |
| Hom | 7 | 7 | 7 |
| Product | 7 (x2 Output+Meta) | 7 (x2 Output+Meta) | 7 |
| Monad | 6 | 5 | 7 |
| IO | 7 | 7 | 7 |
