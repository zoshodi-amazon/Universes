# TEMPLATE.md -- RL-Lab

Lab-specific naming, structural templates, and conventions for the RL-Lab. Extends `Universes/TEMPLATE.md`.

---

## 1. Base Point

| Field | Value |
|-------|-------|
| Lab name | `RL-Lab` |
| Artifact type | Autonomous quant RL pipeline (single-asset) |
| Type language | **Lean 4** (canonical, strata 1-6) -- currently provisional Python |
| IO runtime | Python (pydantic + stable-baselines3 + gymnasium + dry-python/returns) |

---

## 2. Phase Chain (FROZEN)

```
Discovery -> Ingest -> Transform -> Solve -> Eval -> Project -> Compose
```

| # | Phase | Matter | Type Theory | IO Executor | Intuition |
|---|-------|--------|-------------|-------------|-----------|
| 1 | Discovery | BEC | Unit (top) | IODiscoveryPhase | "What universe exists?" |
| 2 | Ingest | Crystalline | Inductive (ADT) | IOIngestPhase | "What data structure?" |
| 3 | Transform | Liquid Crystal | Dependent type | IOTransformPhase | "What geometry?" |
| 4 | Solve | Liquid | Function (A -> B) | IOSolvePhase | "What transformation?" |
| 5 | Eval | Gas | Product/Sum | IOEvalPhase | "What outcomes?" |
| 6 | Project | Plasma | Monad (M A) | IOProjectPhase | "What effects?" |
| 7 | Compose | QGP | IO | IOComposePhase | "Deploy everything" |

**Naming rule:** Phase names are PascalCase in directories (`Types/Hom/Transform/`), lowercase in justfile commands (`cata-transform`).

---

## 3. Type Naming Conventions

### Types/ (Algebraic)

| Category | Pattern | Examples |
|----------|---------|---------|
| Identity | `{Domain}Identity` | `IndexIdentity`, `SessionIdentity` |
| Inductive | `{Domain}Inductive` | `FrameInductive`, `CatalogInductive`, `CatalogEntryInductive`, `IndexMetaInductive`, `SolverInductive`, `SeverityInductive`, `MeasureInductive` |
| Dependent | `{Domain}Dependent` | `ExecutionDependent`, `ConstraintDependent`, `FilterDependent`, `ThresholdDependent`, `SearchDependent` |
| Hom | `{Phase}Hom` | `DiscoveryHom`, `IngestHom`, `TransformHom`, `SolveHom`, `EvalHom`, `ProjectHom`, `ComposeHom` |
| Product Output | `{Phase}ProductOutput` | `DiscoveryProductOutput`, `SolveProductOutput` |
| Product Meta | `{Phase}ProductMeta` | `DiscoveryProductMeta`, `SolveProductMeta` |
| Monad | `{Domain}Monad` | `ErrorMonad`, `MeasureMonad`, `SignalMonad`, `EffectMonad`, `StoreMonad`, `ArtifactMonad` |

### CoTypes/ (Coalgebraic)

| CoCategory | Pattern | Examples |
|------------|---------|---------|
| CoIdentity | `Co{Domain}Identity` | `CoIndexIdentity`, `CoSessionIdentity` |
| CoInductive | `Co{Domain}Inductive` | `CoFrameInductive`, `CoCatalogInductive`, `CoSolverInductive` |
| CoDependent | `Co{Domain}Dependent` | `CoExecutionDependent`, `CoConstraintDependent`, `CoFilterDependent` |
| CoHom | `Co{Phase}Hom` | `CoDiscoveryHom`, `CoSolveHom`, `CoComposeHom` |
| CoProduct Output | `Co{Phase}ProductOutput` | `CoDiscoveryProductOutput`, `CoSolveProductOutput` |
| CoProduct Meta | `Co{Phase}ProductMeta` | `CoDiscoveryProductMeta`, `CoSolveProductMeta` |
| Comonad | `{Domain}Comonad` or `Co{Domain}Comonad` | `TraceComonad`, `CoErrorComonad`, `CoStoreComonad` |

### Naming Normalization

All type names, phase names, and field names follow the Naming Normalization Protocol (root TEMPLATE.md Section 16). Domain jargon is confined to Inductive variant constructors, `io_` prefixed fields, and IO executor internals.

---

## 4. Python Realization

All types are `pydantic.BaseModel` subclasses. IO executors use `pydantic_settings.BaseSettings` with JSON + CLI sources. Monadic IO via `dry-python/returns`.

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
from returns.io import IOResult, impure_safe
from returns.result import safe

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

@impure_safe
def run(cfg: {Phase}Hom, store: StoreMonad) -> {Phase}ProductOutput:
    """The profunctor arrow: Hom -> Product via IO."""
    ...

if __name__ == "__main__":
    settings = Settings()
    result = run(settings.{phase}, settings.store)
    # result : IOResult[{Phase}ProductOutput, Exception]
```

### Observer Pattern (CoTypes/CoIO/)

```python
"""CoIO{Phase}Phase [CoIO] -- Description."""
from returns.io import IOResult, impure_safe

class Settings(BaseSettings):
    """CoIO{Phase}Phase Settings (<=7 fields)."""
    {phase}: Co{Phase}Hom = Co{Phase}Hom()  # what to check
    store: StoreMonad = StoreMonad()         # where to probe

@impure_safe
def run(cfg: Co{Phase}Hom, store: StoreMonad) -> Co{Phase}ProductOutput:
    """The observation comorphism: CoHom -> CoProduct via CoIO."""
    ...
```

### Monadic Surface (`dry-python/returns`)

| Container | Usage | Example |
|-----------|-------|---------|
| `IOResult[T, ErrorMonad]` | Every IO executor return | `run() -> IOResult[SolveProductOutput, ErrorMonad]` |
| `Result[T, ErrorMonad]` | Pure fallible computation | Schema validation, parsing |
| `Maybe[T]` | Optional value (no None) | `store.get(phase, key) -> Maybe[ArtifactMonad]` |
| `@safe` | Pure exception capture | `@safe` on validation helpers |
| `@impure_safe` | IO exception capture | `@impure_safe` on `run()` |
| `flow()` / `pipe()` | Pipeline composition | Phase chaining in IOComposePhase |

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
| `.pkl` | Product (blob) | Pickled DataFrames (ingest, transform), VecNormalize stats |
| `.zip` | Product (blob) | SB3 model archives (model.zip) |
| `.jsonl` | Product (blob) | Audit trail (one JSON object per line) |
| `.db` | Identity (store) | SQLite artifact database (`store/.rl.db`) |

---

## 6. Justfile Command Surface

15 commands: 6 cata- (production) + 7 ana-{phase} (observation) + 1 ana-check (cross-cutting) + 1 hylo-compose (composite).

| Prefix | Count | Pattern | Example |
|--------|:-----:|---------|---------|
| `cata-` | 6 | `cata-{phase}` | `cata-discover`, `cata-solve` |
| `ana-` | 7 | `ana-{phase}` | `ana-discover`, `ana-compose` |
| `ana-` | 1 | `ana-check` (cross-cutting) | `ana-check` |
| `hylo-` | 1 | `hylo-compose` | `hylo-compose` |

### Dissolved Commands (no longer in justfile)

| Former Command | Absorbed Into | Activation |
|---------------|---------------|-----------|
| `ana-tail` | `ana-compose` | Default (CoIOComposePhase) |
| `ana-visualize` | `ana-compose` | `--compose.visualize true` |
| `ana-render` | `ana-eval` | `--eval.launch_renderer true` |
| `ana-validate` | `ana-compose` / `ana-check` | `--compose.validate_imports true --compose.validate_fields true --compose.validate_json true` |

---

## 7. Profunctor Triad (per phase)

Every phase follows the universal profunctor pattern:

### Production (Types/)

```
Types/Hom/{Phase}/default.py             -- Domain: {Phase}Hom
Types/IO/IO{Phase}Phase/default.json     -- Serialized Hom (IO boundary)
Types/IO/IO{Phase}Phase/default.py       -- Arrow: run(Hom, Store) -> IOResult[ProductOutput, ErrorMonad]
Types/Product/{Phase}/Output/default.py  -- Codomain output: {Phase}ProductOutput
Types/Product/{Phase}/Meta/default.py    -- Codomain meta: {Phase}ProductMeta
```

### Observation (CoTypes/)

```
CoTypes/CoHom/{Phase}/default.py                    -- Spec: Co{Phase}Hom (what to check)
CoTypes/CoIO/CoIO{Phase}Phase/default.json          -- Serialized CoHom (IO boundary)
CoTypes/CoIO/CoIO{Phase}Phase/default.py            -- Probe: run(CoHom, Store) -> IOResult[CoProductOutput, ErrorMonad]
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
