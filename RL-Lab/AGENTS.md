# AGENTS.md -- Design Invariants

Rules for any agent (human or AI) working on this codebase.
**Read this file and README.md before every update.**

## Project Files

| File | Purpose |
|------|---------|
| `README.md` | System design + implementation plan + Definition of Done checklist |
| `AGENTS.md` | Design invariants and rules (this file) |
| `DICTIONARY.md` | Domain terms mapped to type-theoretic placements |
| `TRACKER.md` | Change log, bug tracker, progress toward Done |
| `justfile` | Single IO interface — all phase invocations |

## Core Project Goal

Autonomous self-hosted quant RL lab:
- Asset-agnostic: stocks, crypto, forex via AssetIdentity index type
- Hot-swappable discovery via yfinance screener + ADX regime filtering (highest-ADX ticker chosen)
- Smooth input geometry via wavelet (db4) on OHLCV + trend proxy (ADX/SuperTrend)
- SB3 VecNormalize for obs/reward (only enhancement layer)
- gym-trading-env default reward untouched, per-step stop-loss/take-profit in eval/serve
- Walk-forward batch backtest via IOMainPhase
- Optional Optuna hyperparameter optimization via `--main.optimize true`
- Train/eval/serve env symmetry: same EnvDependent, broker_mode toggles sim/paper/live

## Process Invariants

- **Docs first.** Update AGENTS.md and README.md before any code change.
- **Read before write.** Re-read both docs before every update.
- **justfile is the only interface.** All phase execution goes through `just {command}`. No raw `python -m` commands. CLI overrides via pydantic-settings: `just hylo-main --train.total_timesteps 10000`. The justfile is the single source of truth for how phases are invoked.

## Justfile Commands as Morphisms (6-Functor Formalism)

Every justfile command is a classified morphism. Three prefixes, no exceptions (root AGENTS.md invariant 17):

| Prefix | Recursion Scheme | Direction | Maps To |
|--------|-----------------|-----------|---------|
| `cata-` | Catamorphism (fold) | Types/ -> Artifact | Production |
| `ana-` | Anamorphism (unfold) | Artifact -> CoTypes/ | Observation |
| `hylo-` | Hylomorphism (unfold+fold) | Composite | ana then cata |

### Production Commands (cata-)

| Command | 6FF | IO Executor |
|---------|-----|-------------|
| `cata-discover` | f! shriek push | IODiscoveryPhase |
| `cata-ingest` | f! shriek push | IOIngestPhase |
| `cata-feature` | f! shriek push | IOFeaturePhase |
| `cata-train` | f! shriek push | IOTrainPhase |
| `cata-eval` | f! shriek push | IOEvalPhase |
| `cata-serve` | f! shriek push | IOServePhase |

### Observation Commands (ana-)

| Command | 6FF | What It Observes |
|---------|-----|-----------------|
| `ana-discover` | f* pullback | Last DiscoveryProductOutput from store |
| `ana-ingest` | f* pullback | Last IngestProductOutput |
| `ana-feature` | f* pullback | FeatureProductOutput geometry stats |
| `ana-train` | f* pullback | TrainProductOutput learning curves |
| `ana-eval` | f* pullback | EvalProductOutput return/drawdown |
| `ana-serve` | f* pullback | ServeProductOutput broker/audit |
| `ana-main` | f* pullback | MainProductOutput pipeline summary |

### Composite Commands (hylo-)

| Command | 6FF | Composition |
|---------|-----|-------------|
| `hylo-main` | tensor | discover -> ingest -> feature -> train -> eval (walk-forward) |
| `hylo-optimize` | tensor | Optuna HPO wrapping train -> eval |

## Frozen Phase Chain (7 Phases)

```
Discovery -> Ingest -> Feature -> Train -> Eval -> Serve -> Main
```

7 phases mapping to 7 states of matter (coldest to hottest):

| # | Matter | Phase | IO Executor | Type Theory | Intuition |
|---|--------|-------|-------------|-------------|-----------|
| 1 | BEC | Discovery | IODiscoveryPhase | Unit (⊤) | "What universe exists?" |
| 2 | Crystalline | Ingest | IOIngestPhase | Inductive (ADT) | "What data structure?" |
| 3 | Liquid Crystal | Feature | IOFeaturePhase | Dependent type | "What geometry?" |
| 4 | Liquid | Train | IOTrainPhase | Function (A → B) | "What transformation?" |
| 5 | Gas | Eval | IOEvalPhase | Product/Sum | "What outcomes?" |
| 6 | Plasma | Serve | IOServePhase | Monad (M A) | "What effects?" |
| 7 | QGP | Main | IOMainPhase | IO | "Deploy everything" |

## 1:1 Phase Mapping

Every phase has exactly: Hom + ProductOutput + ProductMeta + IO executor + justfile entry. No exceptions.

| Phase | Hom (input) | ProductOutput | IO Executor | justfile |
|-------|-------------|---------------|-------------|----------|
| Discovery | DiscoveryHom | DiscoveryProductOutput | IODiscoveryPhase | `cata-discover` |
| Ingest | IngestHom | IngestProductOutput | IOIngestPhase | `cata-ingest` |
| Feature | FeatureHom | FeatureProductOutput | IOFeaturePhase | `cata-feature` |
| Train | TrainHom | TrainProductOutput | IOTrainPhase | `cata-train` |
| Eval | EvalHom | EvalProductOutput | IOEvalPhase | `cata-eval` |
| Serve | ServeHom | ServeProductOutput | IOServePhase | `cata-serve` |
| Main | MainHom | MainProductOutput | IOMainPhase | `hylo-main` |

## IO Executors (Types/IO/)

Every IO executor is a self-contained QGP-layer module with its own `BaseSettings` + `default.json` + `run()` + `__main__`. It reads typed config, calls external services, and writes artifacts. No IO executor defines types — all types live in `Types/`.

- **IODiscoveryPhase** — Phase 1 (BEC): screener + ADX filter
- **IOIngestPhase** — Phase 2 (Crystalline): download + cache OHLCV
- **IOFeaturePhase** — Phase 3 (Liquid Crystal): wavelet denoise + trend indicators
- **IOTrainPhase** — Phase 4 (Liquid): RL training with SB3
- **IOEvalPhase** — Phase 5 (Gas): out-of-sample evaluation
- **IOServePhase** — Phase 6 (Plasma): live bar-by-bar serving with broker execution + audit logging
- **IOMainPhase** — Phase 7 (QGP): full pipeline + optional Optuna optimization

## Per-Phase Settings

- Each `Types/IO/IO{X}Phase/` has its own `default.py` (BaseSettings + logic + `__main__`) and `default.json`
- Each phase is self-contained: reads its own JSON, accepts CLI overrides, no cross-phase imports for settings
- `default.json` is committed — it is the IO boundary, equivalent to a lock file
- No monolithic Config. No PhaseConfig wrapper.

## Matter-Phase Type System

Types follow the free ⊣ forgetful adjunction, mapped to phases of matter:

| Phase | Layer | Description |
|-------|-------|-------------|
| **Identity** | `Types/Identity/` | Terminal objects — types with exactly one inhabitant; shared fixed points |
| **Inductive** | `Types/Inductive/` | Sum types / ADTs — structural validation, finite enums, external data schemas |
| **Dependent** | `Types/Dependent/` | Parameterized configs — indexed type families |
| **Hom** | `Types/Hom/` | Phase inputs — morphisms flowing into phases |
| **Product** | `Types/Product/` | Phase outputs + meta — computed results expanding outward |
| **Monad** | `Types/Monad/` | Effect record types — errors, metrics, alarms, observability, store |
| **IO** | `Types/IO/` | IO executors — BaseSettings + run() + __main__ per phase |

## Architectural Pattern

- `Types/Identity/` — [BEC] terminal objects; `Unit (⊤)` — types with exactly one canonical inhabitant (plain `BaseModel`)
- `Types/Inductive/` — [Crystalline] sum types / ADTs for external data and finite enums (plain `BaseModel` + validators)
- `Types/Dependent/` — [Liquid Crystal] parameterized configs, indexed type families (plain `BaseModel`)
- `Types/Hom/` — [Liquid] phase inputs, morphisms flowing in (plain `BaseModel`)
- `Types/Product/` — [Gas] phase outputs + meta extensions (plain `BaseModel`)
- `Types/Monad/` — [Plasma] effect record types composed into meta (plain `BaseModel`)
- `Types/IO/` — [QGP] IO executors, each with own `BaseSettings` + `default.json`

## Naming Invariants

- **All filenames must be `default.*`** — `default.py` for code, `default.json` for config. The only exception is `__init__.py`. No other filenames are permitted under `Types/` or `CoTypes/`.
- **All directory names must start with an uppercase letter** — `Types/Hom/Feature/`, not `Types/Hom/feature/`. This applies to every directory under `Types/` and `CoTypes/`.
- `{Domain}Identity` — terminal/identity type [Identity] — exactly one canonical inhabitant
- `{Domain}Inductive` — structural validation or sum type [Inductive] — ADTs, finite enums, external data
- `{Domain}Dependent` — parameterized config type [Dependent]
- `{Domain}Hom` — phase input type [Hom]
- `{Domain}Product{Kind}` — phase output or meta type [Product]
- `{Domain}Monad` — effect record type [Monad]
- `IO{Phase}Phase` — IO executor in `Types/IO/` [IO]
- `AlgoIdentity` lives in `Types/Inductive/Algo/` — it is a 4-variant sum type (ADT), Crystalline phase
- `AlarmSeverity` lives in `Types/Inductive/AlarmSeverity/` — 3-variant ADT replacing bare Literal
- `MetricKind` lives in `Types/Inductive/MetricKind/` — 2-variant ADT replacing bare Literal
- `ArtifactRow` lives in `Types/Monad/Artifact/` — extracted from StoreMonad per 1-type-per-file invariant
- IOMainPhase instantiates sub-phase Hom types locally with defaults — it is a parameterized wrapper, not a config aggregator
- Every phase has exactly: Hom + ProductOutput + ProductMeta + IO executor + justfile entry

## Type Phase Mapping

Phases are symmetry/Lie groups. Types within the same phase share the same symmetry structure.
Directory encodes phase — intra-phase naming is cognitive semantic separation only.
Inter-phase transitions are symmetry-breaking functors (6-functor formalism adjunctions).

| # | Phase | Type Theory | Matter | Directory | Naming | Count |
|---|-------|-------------|--------|-----------|--------|-------|
| 1 | Identity | Unit (⊤) | BEC | `Types/Identity/` | `{Domain}Identity` | 2 |
| 2 | Inductive | ADT | Crystalline | `Types/Inductive/` | `{Domain}Inductive` | 7 |
| 3 | Dependent | Indexed | Liquid Crystal | `Types/Dependent/` | `{Domain}Dependent` | 5 |
| 4 | Hom | Function | Liquid | `Types/Hom/` | `{Domain}Hom` | 7 |
| 5 | Product | Sum/Product | Gas | `Types/Product/` | `{Domain}Product{Kind}` | 14 |
| 6 | Monad | Effect | Plasma | `Types/Monad/` | `{Domain}Monad` | 6 |
| 7 | IO | IO | QGP | `Types/IO/` | `IO{Phase}Phase` | 7 |

## Product Types (Outputs + Meta)

Each phase has Output + Meta within the same Product symmetry group:

| Phase | Output Class | Meta Class |
|-------|-------------|------------|
| Discovery | DiscoveryProductOutput | DiscoveryProductMeta |
| Ingest | IngestProductOutput | IngestProductMeta |
| Feature | FeatureProductOutput | FeatureProductMeta |
| Train | TrainProductOutput | TrainProductMeta |
| Eval | EvalProductOutput | EvalProductMeta |
| Serve | ServeProductOutput | ServeProductMeta |
| Main | MainProductOutput | MainProductMeta |

## Production Safeguards (IOServePhase)

IOServePhase includes the following safeguards for live trading:

- **Stop-loss check** — per-step return check, flattens position if breached
- **Take-profit check** — exits on profit threshold
- **Max drawdown circuit breaker** — tracks peak portfolio value, flattens if drawdown exceeds `risk.max_drawdown_pct`
- **Model staleness check** — rejects models older than `max_model_age_min`
- **Data freshness check** — rejects data older than 7 days
- **Feature validation** — ensures feature columns exist
- **Graceful shutdown** — SIGINT/SIGTERM handling with position flattening
- **Audit logging** — every position change logged to `store/blobs/{run_id}/audit/audit_{run_ts}_{run_id}.jsonl`

## Type Invariants

1. **≤7 fields per type** — >7 signals the type spans more than one symmetry group; decompose.
2. **Every field has `Field(description=...)`** — types are documentation.
3. **Every field bounded** — `ge=`/`le=` for numerics, `min_length=`/`max_length=` for strings. No unbounded types. No `Optional`/`None`. No placeholders. No `NaN`.
4. **Sentinel values for "not set"** — use `-1.0`, `-1`, `""` rather than `None`.
5. **Field Independence** — no field on a type is derivable from another field on the same type (coordinate chart: each field is an independent generator).
6. **Field Completeness** — the field set spans the full degree of freedom for this type's domain; no missing config axis.
7. **Field Locality** — each field belongs to this phase's domain only; shared params move to `Identity/` or `Dependent/`.
8. **No named type aliases** — constraints live inline: `Annotated[str, StringConstraints(...)]` or `Field(ge=, le=)` directly. No `RunId = Annotated[...]` at module scope.
9. **No cross-Hom imports** — shared enums/types live in `Identity/` or `Inductive/` or `Dependent/`, never imported from another `Hom/` type.
10. **One type per `default.py`** — supporting enums acceptable in same file; no nested hidden classes.
11. **Fully qualified imports** — `from Types.Identity.Asset.default import AssetIdentity`. No wildcard imports.
12. **External data through Inductive types** — `OHLCVInductive.from_dataframe()`, `ScreenerInductive.from_response()`, `TickerInfoInductive.from_info()`. No raw dicts crossing IO boundary.
13. **Phases are symmetry groups** — directory encodes phase; class names use `{Domain}{PhaseType}` convention.
14. **Every function has typed IO** — all parameters and return types annotated. No exceptions.
15. **Meta extends Product symmetry group** — when more observables are needed, add Meta types, not Output fields.
16. **Input sanitization via pydantic** — users cannot set values outside bounded fields. No manual validation.
17. **Eval/Serve env parity** — `Types/Dependent/Env/` and `Types/Dependent/Risk/` are the parity contract; not shared implementation.
18. **`default.json` is committed** — it is the IO boundary, equivalent to a lock file. Regenerate via `just ana-check` when types change.
19. **Invariants are never traded away for convenience** — there are no exceptions to phase placement rules. If a type feels like it belongs in a different phase for import-isolation reasons or any other practical reason, the type must move to its correct phase. Suggesting or accepting an "exception" to a type-theoretic invariant is an anti-pattern.
20. **Phase placement is determined solely by type theory** — Identity = `Unit (⊤)` (one inhabitant), Inductive = sum/product ADTs and finite enums, Dependent = indexed/parameterized types, Hom = morphisms in, Product = morphisms out, Monad = effect types, IO = executors. Semantic convenience never overrides this.

## Anti-Patterns

- Nested classes in `default.py` → each type gets its own `default.py`
- Untyped function → every function has typed parameters and return
- Wildcard or relative imports → use fully qualified paths
- Unvalidated external data → wrap in Inductive types
- Type suffix mismatch → suffix must match phase (`{Domain}Identity`, `{Domain}Hom`, etc.)
- Named type alias at module scope → inline constraints at the field with `Annotated`
- `options` block in IO executor → all typing lives in `Types/`; IO executors only read JSON
- `null` / `""` / `-1` as sentinel without documenting intent → document in `Field(description=...)`
- Cross-Hom import → shared type belongs in `Identity/`, `Inductive/`, or `Dependent/`
- Placing a finite enum in `Identity/` → enums are sum types (ADTs), they belong in `Inductive/`
- `Literal["a", "b"]` for finite variants → extract to `Inductive/` as `str, Enum` ADT
- `except Exception: pass` or `except Exception: continue` → all errors must be typed through ErrorMonad
- `except (KeyError, Exception)` → redundant; `Exception` is superclass of `KeyError`
- `hasattr(order, "filled_qty")` → use `order.status` for fill verification
- Cross-phase Hom aggregator types (`PipelineHom`, `ServeInputHom`) → each phase instantiates Hom defaults locally
- "Exception" to a phase placement rule → there are no exceptions; move the type

## File Responsibilities

| Location | Does | Does NOT |
|----------|------|----------|
| `Types/Identity/` | Terminal object type definitions (one canonical inhabitant) | Logic, configs, IO, enums |
| `Types/Inductive/` | Sum types, ADTs, finite enums, external data validation schemas | Business logic |
| `Types/Dependent/` | Parameterized config types | Phase logic |
| `Types/Hom/` | Phase input type definitions | Output types, effects |
| `Types/Product/` | Phase output + meta type definitions | Input types, configs |
| `Types/Monad/` | Effect record type definitions (errors, metrics, store) | Phase logic |
| `store/` | Runtime artifact DB + blobs: models, pickles, audit logs, docs | Source code |

## Modification Rules

- **Docs first.** Always.
- To change a parameter: edit the phase's `default.json` under `Types/IO/IO{X}Phase/`.
- To change bounds: edit the typed `BaseModel` in `Types/`.
- To add a phase: add `{Domain}Hom` + `{Domain}ProductOutput` + `{Domain}ProductMeta` in `Types/`, add `IO{X}Phase` in `Types/IO/`, update all frozen tables in README.md and AGENTS.md.
- Every phase has exactly: Hom + ProductOutput + ProductMeta + IO executor + justfile entry.

## CoTypes/ — Coalgebraic Dual (1-1 Correspondence)

`CoTypes/` is the coalgebraic dual of `Types/`. Where `Types/` builds up (constructors, functors flowing in), `CoTypes/` tears down (destructors, observations flowing out).

Every category in Types/ has exactly one dual in CoTypes/. 1-1 correspondence. No exceptions. (Root AGENTS.md invariant 3.)

### Full 7-Category Duality

| # | Types/ | CoTypes/ | Duality | CoTypes/ Contains |
|---|--------|----------|---------|-------------------|
| 1 | `Identity/` | `CoIdentity/` | Terminal <-> Coterminal | Introspection witnesses: is ticker valid? is store reachable? are blobs intact? |
| 2 | `Inductive/` | `CoInductive/` | Free <-> Cofree | Elimination forms: can we parse every OHLCV/Screener variant? schema validators |
| 3 | `Dependent/` | `CoDependent/` | Fibration <-> Cofibration | Lifting property: does default.json conform to Dependent schemas? bounds respected? |
| 4 | `Hom/` | `CoHom/` | Constructors <-> Destructors | Observation specs: what to check per phase (field-parallel with Bool/Option types) |
| 5 | `Product/` | `CoProduct/` | Product <-> Coproduct | Observation results: what the observer actually saw per phase (Output + Meta) |
| 6 | `Monad/` | `Comonad/` | Effects <-> Co-effects | Observation traces: TraceComonad + CoErrorComonad + CoMetricComonad + CoAlarmComonad + CoStoreComonad |
| 7 | `IO/` | `CoIO/` | Executors <-> Observers | Observer executors: probe artifact state, compare against CoHom |

**Current status:** All 7 categories populated. Categories 4-7 have both types and executors. Categories 1-3 have types (observation witnesses) but no dedicated CoIO executors — they are probed inline by the per-phase observers. Comonad/ has 5 types: Trace, Error, Metric, Alarm, Store.

**Naming:** `CoTypes/CoIO/` (not `CoTypes/IO/`). `CoTypes/Comonad/` (standard math spelling, not `CoMonad/`). See root TEMPLATE.md.

### Observer 1-1-1 Invariant

Every observer has exactly: `CoHom` + `CoProduct{Output,Meta}` + `CoIO executor` + `justfile entry`.

Observer executors are covariant presheaves — they observe the system without participating in the phase chain. They do NOT appear in the frozen phase chain table.

### Per-Phase Observation Duals

Each of the 7 production phases has its own observation triad: `CoHom(phase) -> CoIO observer -> CoProduct(phase)`. Validate and Visualize logic is absorbed into CoIOMainPhase (Phase 7 composite). Render logic is absorbed into CoIOEvalPhase.

| Phase | CoHom | CoIO Observer | CoProduct | justfile | Status |
|-------|-------|---------------|-----------|----------|--------|
| Discovery | `CoDiscoveryHom` | `CoTypes/CoIO/CoIODiscoveryPhase/` | `CoDiscoveryProductOutput` | `ana-discover` | DONE |
| Ingest | `CoIngestHom` | `CoTypes/CoIO/CoIOIngestPhase/` | `CoIngestProductOutput` | `ana-ingest` | DONE |
| Feature | `CoFeatureHom` | `CoTypes/CoIO/CoIOFeaturePhase/` | `CoFeatureProductOutput` | `ana-feature` | CoHom+CoIO done; CoProduct stub |
| Train | `CoTrainHom` | `CoTypes/CoIO/CoIOTrainPhase/` | `CoTrainProductOutput` | `ana-train` | CoHom+CoIO done; CoProduct stub |
| Eval | `CoEvalHom` | `CoTypes/CoIO/CoIOEvalPhase/` | `CoEvalProductOutput` | `ana-eval` | CoHom+CoIO done; CoProduct stub |
| Serve | `CoServeHom` | `CoTypes/CoIO/CoIOServePhase/` | `CoServeProductOutput` | `ana-serve` | CoHom+CoIO done; CoProduct stub |
| Main | `CoMainHom` | `CoTypes/CoIO/CoIOMainPhase/` | `CoMainProductOutput` | `ana-main` | DONE |

### Comonad Types (5)

`CoTypes/Comonad/` contains 5 observation witness types — duals of the 5 Monad types:

| Comonad Type | Dual Of | Fields | Purpose |
|-------------|---------|--------|---------|
| `TraceComonad` | `ObservabilityMonad` | observer_id, cursor, events_seen, connection_ok, last_seen_at | Observation cursor state |
| `CoErrorComonad` | `ErrorMonad` | error_count, has_fatal, worst_severity, last_message | Error observation summary |
| `CoMetricComonad` | `MetricMonad` | metric_count, has_counters, has_gauges, value_range | Metric observation summary |
| `CoAlarmComonad` | `AlarmMonad` | alarm_count, has_critical, worst_severity, last_name | Alarm observation summary |
| `CoStoreComonad` | `StoreMonad` | db_reachable, artifact_count, blob_dir_exists, latest_created, disk_usage_mb | Store health witness |

`CoPhaseId` enum (in Trace) identifies observer executors: 7 variants matching canonical phases. Distinct from `PhaseId` in `Types/Monad/Error/`.

### Bidirectional Path Closure

CoTypes/ is the bidirectional path closure witness. Two observation paths must agree:

**Path (a) — Schema observation (pure):** `Hom -> toJson -> fromJson -> Hom` roundtrip closure. Validated by `ana-main --main.validate_json true` or `ana-check`.

**Path (b) — Runtime observation (effectful):** `Product -> CoIO observer -> CoProduct`. Each ana-{phase} command pulls the last ProductOutput from StoreMonad and populates CoProduct.

Agreement between paths (a) and (b) is the proof that the IO executor did what the types said it would.

### CoTypes Invariants

21. **`CoTypes/` maintains 1-1 duality with `Types/`** — 7 categories, no exceptions: `CoIdentity↔Identity`, `CoInductive↔Inductive`, `CoDependent↔Dependent`, `CoHom↔Hom`, `CoProduct↔Product`, `Comonad↔Monad`, `CoIO↔IO`.
22. **Observer executors follow 1-1-1 invariant** — `CoHom + CoProduct{Output,Meta} + CoIO executor + justfile entry` — but are NOT in the frozen phase chain table.
23. **`CoPhaseId` separate from `PhaseId`** — observer errors use `CoPhaseId`; algebraic and coalgebraic error enums are distinct.
24. **`StoreMonad` is the typed IO boundary** — no hardcoded paths in IO executors; all path resolution goes through `run_base.store.*` (`db_url`, `blob_dir`, `blob_path_for()`, `put()`, `get()`).
25. **`store/docs/tracker/`** is the canonical location for session tracker markdown files.
26. **`sseclient-py` and `rerun-sdk`** are declared dependencies in `pyproject.toml`. CoTypes observers require them.
27. **Every `cata-*` has an `ana-*` dual** — testing IS coalgebraic observation. The ana- command for a phase probes the artifact that cata- produced.
28. **Bidirectional path closure** — schema test (path a) + runtime observation (path b) both yield CoProduct. If they agree, the system is correct.
