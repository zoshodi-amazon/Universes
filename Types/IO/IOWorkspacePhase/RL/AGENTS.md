# AGENTS.md -- Design Invariants

Rules for any agent (human or AI) working on this codebase.
**Read this file and README.md before every update.**

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
- **justfile is the only interface.** All phase execution goes through `just {phase}`. No raw `python -m` commands. CLI overrides via pydantic-settings: `just main --train.total_timesteps 10000`. The justfile is the single source of truth for how phases are invoked.

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
| Discovery | DiscoveryHom | DiscoveryProductOutput | IODiscoveryPhase | `discover` |
| Ingest | IngestHom | IngestProductOutput | IOIngestPhase | `ingest` |
| Feature | FeatureHom | FeatureProductOutput | IOFeaturePhase | `feature` |
| Train | TrainHom | TrainProductOutput | IOTrainPhase | `train` |
| Eval | EvalHom | EvalProductOutput | IOEvalPhase | `eval` |
| Serve | ServeHom | ServeProductOutput | IOServePhase | `serve` |
| Main | MainHom | MainProductOutput | IOMainPhase | `main` |

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

- `{Domain}Identity` — terminal/identity type [Identity] — exactly one canonical inhabitant
- `{Domain}Inductive` — structural validation or sum type [Inductive] — ADTs, finite enums, external data
- `{Domain}Dependent` — parameterized config type [Dependent]
- `{Domain}Hom` — phase input type [Hom]
- `{Domain}Product{Kind}` — phase output or meta type [Product]
- `{Domain}Monad` — effect record type [Monad]
- `IO{Phase}Phase` — IO executor in `Types/IO/` [IO]
- `AlgoIdentity` lives in `Types/Inductive/Algo/` — it is a 4-variant sum type (ADT), Crystalline phase
- Every phase has exactly: Hom + ProductOutput + ProductMeta + IO executor + justfile entry

## Type Phase Mapping

Phases are symmetry/Lie groups. Types within the same phase share the same symmetry structure.
Directory encodes phase — intra-phase naming is cognitive semantic separation only.
Inter-phase transitions are symmetry-breaking functors (6-functor formalism adjunctions).

| # | Phase | Type Theory | Matter | Directory | Naming | Count |
|---|-------|-------------|--------|-----------|--------|-------|
| 1 | Identity | Unit (⊤) | BEC | `Types/Identity/` | `{Domain}Identity` | 2 |
| 2 | Inductive | ADT | Crystalline | `Types/Inductive/` | `{Domain}Inductive` | 5 |
| 3 | Dependent | Indexed | Liquid Crystal | `Types/Dependent/` | `{Domain}Dependent` | 5 |
| 4 | Hom | Function | Liquid | `Types/Hom/` | `{Domain}Hom` | 7 |
| 5 | Product | Sum/Product | Gas | `Types/Product/` | `{Domain}Product{Kind}` | 14 |
| 6 | Monad | Effect | Plasma | `Types/Monad/` | `{Domain}Monad` | 5 |
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
18. **`default.json` is committed** — it is the IO boundary, equivalent to a lock file. Regenerate via `just types-validate` when types change.
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

## CoTypes/ — Coalgebraic Dual

`CoTypes/` is the coalgebraic dual of `Types/`. Where `Types/` builds up (constructors, functors flowing in), `CoTypes/` tears down (destructors, observations flowing out).

```
Types/Identity/   ↔   (no CoTypes dual — shared by both)
Types/Hom/        ↔   CoTypes/CoHom/
Types/Product/    ↔   CoTypes/CoProduct/
Types/Monad/      ↔   CoTypes/Comonad/
Types/IO/         ↔   CoTypes/IO/
```

Observer executors are covariant presheaves — they observe the system without participating in the phase chain. They do NOT appear in the frozen phase chain table.

### Observer 1-1-1 Invariant

Every observer has exactly: `CoHom` + `CoProduct{Output,Meta}` + `IO executor` + `justfile entry`.

| Observer | CoHom | CoProductOutput | IO Executor | justfile |
|----------|-------|-----------------|-------------|----------|
| Tail | `TailCoHom` | `TailCoProductOutput` | `IOTailPhase` | `tail` |
| Visualize | `VisualizeCoHom` | `VisualizeCoProductOutput` | `IOVisualizePhase` | `visualize` |

### CoType Phase Mapping

| Layer | Directory | Naming | Dual of |
|-------|-----------|--------|---------|
| CoHom | `CoTypes/CoHom/` | `{Domain}CoHom` | `Types/Hom/` |
| CoProduct | `CoTypes/CoProduct/` | `{Domain}CoProduct{Kind}` | `Types/Product/` |
| Comonad | `CoTypes/Comonad/` | `{Domain}Comonad` | `Types/Monad/` |
| CoIO | `CoTypes/IO/` | `IO{Observer}Phase` | `Types/IO/` |

### TraceComonad

`TraceComonad` in `CoTypes/Comonad/Trace/` is the dual of `ObservabilityMonad`. Fields:
- `observer_id` — identity of observer instance
- `cursor` — current position in observation space (SSE event id or last file path)
- `events_seen` — monotonically increasing counter
- `connection_ok` — liveness boolean
- `last_seen_at` — ISO timestamp

`CoPhaseId` enum (in same file) identifies observer executors: `tail | visualize`. Distinct from `PhaseId` in `Types/Monad/Error/` — observer errors never mix with pipeline errors.

### CoTypes Invariants

21. **`CoTypes/` is the coalgebraic dual** — final coalgebras, destructors, observations flowing OUT; mirrors: `CoHom↔Hom`, `CoProduct↔Product`, `Comonad↔Monad`, `IO↔IO`
22. **Observer executors follow 1-1-1 invariant** — `CoHom + CoProduct{Output,Meta} + IO executor + justfile entry` — but are NOT in the frozen phase chain table.
23. **`CoPhaseId` separate from `PhaseId`** — observer errors use `CoPhaseId`; algebraic and coalgebraic error enums are distinct.
24. **`StoreMonad` is the typed IO boundary** — no hardcoded paths in IO executors; all path resolution goes through `run_base.store.*` (`db_url`, `blob_dir`, `blob_path_for()`, `put()`, `get()`).
25. **`store/docs/tracker/`** is the canonical location for session tracker markdown files.
26. **`sseclient-py` and `rerun-sdk`** are declared dependencies in `pyproject.toml`. CoTypes observers require them.
