# TRACKER.md — Change Log and Progress

Running log of changes, decisions, and progress toward the Definition of Done.
Most recent entries first.

---

## 2026-03-09 — Session 6: Taxonomic Purification Implementation Plan

### What happened
- Explored full codebase: 93 source files, ~150 `__init__.py`, 14 JSON configs, justfile, pyproject.toml
- Confirmed all Session 5 documentation is in place (AGENTS.md, DICTIONARY.md, TEMPLATE.md, README.md, 14 per-stratum READMEs)
- Produced the stratum-by-stratum implementation plan below
- **Audit finding:** A prior session already executed the MAJORITY of the code rename:
  - All 55 directory renames: DONE
  - All class renames (type names in files): DONE
  - Justfile command renames: DONE
  - pyproject.toml version bump + `returns>=0.23` dependency: DONE
  - Most Hom/Product/IO field renames: DONE
- **Remaining gaps** (field/method renames not yet executed):
  - `FrameInductive`: `from_dataframe`→`from_io_frame`, `to_dataframe`→`to_io_frame` (+ 5 call sites in IO executors)
  - `CatalogInductive`: `from_response`→`from_io_response`, `get_tickers`→`indices` (+ 2 call sites)
  - `SessionIdentity`: `name`→`label`
  - `ExecutionDependent`: `positions`→`position_space`
  - `FilterDependent`: 6 old field names (`min_volume_percentile`→`volume_quantile`, etc.)
  - `ThresholdDependent`: 2 old field names (`min_qualifying_tickers`→`min_qualifying_indices`, `max_api_failures`→`max_io_failures`)
  - `SearchDependent`: `n_trials`→`budget`, `n_parallel`→`parallelism`
  - All `default.json` configs referencing these fields
  - `dry-python/returns` integration (T6.9): dependency added, but wrapping not yet done
- Created `PROMPTS.md` (Universes/ + RL-Lab/) — canonical spec-driven prompt library for subagent dispatch
- Committed all code changes: `5821cb8` — 127 files, 2261+/2598- (dirs, classes, fields, JSON, justfile, pyproject)

### Commits

| Hash | Message |
|------|---------|
| `94c9efd` | `[RL-Lab \| Docs] v0.4.0: Session 6 implementation plan` |
| `3f2b68c` | `[Docs \| CoIO] v7.2.1: Add PROMPTS.md` |
| `5821cb8` | `[RL-Lab \| Refactor] v0.4.0: Taxonomic purification` |

### Implementation Plan (T6 — Code Rename)

The coding session will execute **bottom-up, stratum by stratum**. Each stratum involves: (1) `git mv` directory renames, (2) class/field/method renames inside files, (3) `__init__.py` export updates, (4) cross-stratum import path updates. After all strata, JSON configs, justfile, and pyproject.toml are updated. Finally `dry-python/returns` is integrated.

#### T6.1 — Stratum 1: Identity (4 source files)

| Action | Old | New |
|--------|-----|-----|
| Dir rename (Types) | `Types/Identity/Asset/` | `Types/Identity/Index/` |
| Dir rename (Types) | `Types/Identity/Run/` | `Types/Identity/Session/` |
| Dir rename (CoTypes) | `CoTypes/CoIdentity/Asset/` | `CoTypes/CoIdentity/Index/` |
| Dir rename (CoTypes) | `CoTypes/CoIdentity/Run/` | `CoTypes/CoIdentity/Session/` |
| Class rename | `AssetIdentity` | `IndexIdentity` |
| Class rename | `AssetType` | `IndexClass` |
| Class rename | `HolidayCalendar` | `TemporalMask` |
| Class rename | `RunIdentity` | `SessionIdentity` |
| Class rename | `CoAssetIdentity` | `CoIndexIdentity` |
| Class rename | `CoRunIdentity` | `CoSessionIdentity` |
| Field rename | `asset_type` | `index_class` |
| Field rename | `run_id` | `session_id` |
| Field rename | `run_ts` | `session_ts` |
| Field rename | `name` | `label` |

#### T6.2 — Stratum 2: Inductive (14 source files)

| Action | Old | New |
|--------|-----|-----|
| Dir rename (Types) | `Inductive/Algo/` | `Inductive/Solver/` |
| Dir rename (Types) | `Inductive/AlarmSeverity/` | `Inductive/Severity/` |
| Dir rename (Types) | `Inductive/MetricKind/` | `Inductive/Measure/` |
| Dir rename (Types) | `Inductive/OHLCV/` | `Inductive/Frame/` |
| Dir rename (Types) | `Inductive/Screener/` | `Inductive/Catalog/` |
| Dir rename (Types) | `Inductive/ScreenerQuote/` | `Inductive/CatalogEntry/` |
| Dir rename (Types) | `Inductive/TickerInfo/` | `Inductive/IndexMeta/` |
| Dir rename (CoTypes) | `CoInductive/Algo/` | `CoInductive/Solver/` |
| Dir rename (CoTypes) | `CoInductive/OHLCV/` | `CoInductive/Frame/` |
| Dir rename (CoTypes) | `CoInductive/Screener/` | `CoInductive/Catalog/` |
| Dir rename (CoTypes) | `CoInductive/ScreenerQuote/` | `CoInductive/CatalogEntry/` |
| Dir rename (CoTypes) | `CoInductive/TickerInfo/` | `CoInductive/IndexMeta/` |
| Class rename | `AlgoIdentity` | `SolverInductive` |
| Class rename | `AlarmSeverity` | `SeverityInductive` |
| Class rename | `MetricKind` | `MeasureInductive` |
| Class rename | `OHLCVInductive` | `FrameInductive` |
| Class rename | `ScreenerInductive` | `CatalogInductive` |
| Class rename | `ScreenerQuoteInductive` | `CatalogEntryInductive` |
| Class rename | `TickerInfoInductive` | `IndexMetaInductive` |
| Method rename | `from_dataframe` | `from_io_frame` |
| Method rename | `to_dataframe` | `to_io_frame` |
| Method rename | `from_response` | `from_io_response` |
| Method rename | `get_tickers` | `indices` |
| Field rename | `quotes` | `entries` |
| Field rename | `symbol` (CatalogEntry) | `index_symbol` |
| Field rename | `average_volume` | `mean_volume` |
| Field rename | `regular_market_price` | `spot_price` |
| Field rename | `day_high` | `session_high` |
| Field rename | `day_low` | `session_low` |
| Field rename | `market_cap` | `capitalization` |

Note: CoInductive has 5 subdirs (no AlarmSeverity or MetricKind duals).

#### T6.3 — Stratum 3: Dependent (10 source files)

| Action | Old | New |
|--------|-----|-----|
| Dir rename (Types) | `Dependent/Env/` | `Dependent/Execution/` |
| Dir rename (Types) | `Dependent/Risk/` | `Dependent/Constraint/` |
| Dir rename (Types) | `Dependent/Liquidity/` | `Dependent/Filter/` |
| Dir rename (Types) | `Dependent/Alarm/` | `Dependent/Threshold/` |
| Dir rename (Types) | `Dependent/Optimize/` | `Dependent/Search/` |
| Dir rename (CoTypes) | `CoDependent/Env/` | `CoDependent/Execution/` |
| Dir rename (CoTypes) | `CoDependent/Risk/` | `CoDependent/Constraint/` |
| Dir rename (CoTypes) | `CoDependent/Liquidity/` | `CoDependent/Filter/` |
| Dir rename (CoTypes) | `CoDependent/Alarm/` | `CoDependent/Threshold/` |
| Dir rename (CoTypes) | `CoDependent/Optimize/` | `CoDependent/Search/` |
| Class rename | `EnvDependent` | `ExecutionDependent` |
| Class rename | `BrokerMode` | `ExecutionMode` |
| Class rename | `RiskDependent` | `ConstraintDependent` |
| Class rename | `LiquidityDependent` | `FilterDependent` |
| Class rename | `AlarmDependent` | `ThresholdDependent` |
| Class rename | `OptimizeDependent` | `SearchDependent` |
| Field rename | `io_broker_key` | `io_execution_key` |
| Field rename | `positions` | `position_space` |
| Field rename | `min_volume_percentile` | `volume_quantile` |
| Field rename | `min_price_percentile` | `price_quantile` |
| Field rename | `max_spread_pct` | `volatility_bound` |
| Field rename | `min_turnover_pct` | `turnover_quantile` |
| Field rename | `require_shortable` | `require_invertible` |
| Field rename | `min_universe_size` | `min_catalog_size` |
| Field rename | `min_qualifying_tickers` | `min_qualifying_indices` |
| Field rename | `max_api_failures` | `max_io_failures` |
| Field rename | `n_trials` | `budget` |
| Field rename | `n_parallel` (Optimize) | `parallelism` |

#### T6.4 — Stratum 4: Hom (8 source files — 4 renamed phases)

| Action | Old | New |
|--------|-----|-----|
| Dir rename (Types) | `Hom/Feature/` | `Hom/Transform/` |
| Dir rename (Types) | `Hom/Train/` | `Hom/Solve/` |
| Dir rename (Types) | `Hom/Serve/` | `Hom/Project/` |
| Dir rename (Types) | `Hom/Main/` | `Hom/Compose/` |
| Dir rename (CoTypes) | `CoHom/Feature/` | `CoHom/Transform/` |
| Dir rename (CoTypes) | `CoHom/Train/` | `CoHom/Solve/` |
| Dir rename (CoTypes) | `CoHom/Serve/` | `CoHom/Project/` |
| Dir rename (CoTypes) | `CoHom/Main/` | `CoHom/Compose/` |
| Class rename | `FeatureHom` | `TransformHom` |
| Class rename | `TrainHom` | `SolveHom` |
| Class rename | `ServeHom` | `ProjectHom` |
| Class rename | `MainHom` | `ComposeHom` |
| Class rename | `WaveletName` | `BasisInductive` |
| Field rename | `wavelet` | `basis` |
| Field rename | `adx_period` | `trend_period` |
| Field rename | `supertrend_period` | `envelope_period` |
| Field rename | `supertrend_multiplier` | `envelope_multiplier` |
| Field rename | `algo` | `solver` |
| Field rename | `n_envs` | `n_parallel` |
| Field rename | `total_timesteps` | `budget` |
| Field rename | `episode_duration_min` | `horizon_min` |
| Field rename | `normalize_obs` | `normalize_input` |
| Field rename | `normalize_reward` | `normalize_signal` |
| Field rename | `train_run_id` | `solve_session_id` |
| Field rename | `io_algo` | `io_solver` |
| Field rename | `poll_interval_s` | `sample_interval_s` |
| Field rename | `max_bars` | `max_frames` |
| Field rename | `max_model_age_min` | `max_artifact_age_min` |
| Field rename | `forward_steps_min` | `horizon_min` |
| Field rename | `io_universe` | `io_indices` |
| Field rename | `screener` | `catalog_source` |
| Field rename | `min_adx` | `min_trend_score` |
| Field rename | `min_bars` | `min_frame_length` |
| Field rename | `adx_lookback_period` | `trend_lookback` |
| Field rename | `warmup_bars` | `warmup_frames` |
| Field rename | `stride_min` | `stride_min` (unchanged) |
| Field rename | `train_split_pct` | `solve_split_pct` |
| Field rename | `optimize` | `search` |
| Field rename | `optimize_config` | `search_fiber` |

#### T6.5 — Stratum 5: Product (16 source files — 4 renamed phase dirs × Output+Meta)

| Action | Old | New |
|--------|-----|-----|
| Dir rename (Types) | `Product/Feature/` | `Product/Transform/` |
| Dir rename (Types) | `Product/Train/` | `Product/Solve/` |
| Dir rename (Types) | `Product/Serve/` | `Product/Project/` |
| Dir rename (Types) | `Product/Main/` | `Product/Compose/` |
| Dir rename (CoTypes) | `CoProduct/Feature/` | `CoProduct/Transform/` |
| Dir rename (CoTypes) | `CoProduct/Train/` | `CoProduct/Solve/` |
| Dir rename (CoTypes) | `CoProduct/Serve/` | `CoProduct/Project/` |
| Dir rename (CoTypes) | `CoProduct/Main/` | `CoProduct/Compose/` |
| Class rename | `FeatureProductOutput` | `TransformProductOutput` |
| Class rename | `FeatureProductMeta` | `TransformProductMeta` |
| Class rename | `TrainProductOutput` | `SolveProductOutput` |
| Class rename | `TrainProductMeta` | `SolveProductMeta` |
| Class rename | `ServeProductOutput` | `ProjectProductOutput` |
| Class rename | `ServeProductMeta` | `ProjectProductMeta` |
| Class rename | `MainProductOutput` | `ComposeProductOutput` |
| Class rename | `MainProductMeta` | `ComposeProductMeta` |
| Class rename | `MainStatus` | `ComposeStatus` |
| Class rename | `ServeStatus` | `ProjectStatus` |

Note: Discovery, Ingest, Eval phase dirs and class names are unchanged.

#### T6.6 — Stratum 6: Monad (8 source files)

| Action | Old | New |
|--------|-----|-----|
| Dir rename (Types) | `Monad/Alarm/` | `Monad/Signal/` |
| Dir rename (Types) | `Monad/Metric/` | `Monad/Measure/` |
| Dir rename (Types) | `Monad/Observability/` | `Monad/Effect/` |
| Dir rename (CoTypes) | `Comonad/Alarm/` | `Comonad/Signal/` |
| Dir rename (CoTypes) | `Comonad/Metric/` | `Comonad/Measure/` |
| Class rename | `AlarmMonad` | `SignalMonad` |
| Class rename | `MetricMonad` | `MeasureMonad` |
| Class rename | `ObservabilityMonad` | `EffectMonad` |
| Class rename | `ArtifactRow` | `ArtifactMonad` |
| Class rename | `CoAlarmComonad` | `CoSignalComonad` |
| Class rename | `CoMetricComonad` | `CoMeasureComonad` |
| Enum variant | `PhaseId.feature` | `PhaseId.transform` |
| Enum variant | `PhaseId.train` | `PhaseId.solve` |
| Enum variant | `PhaseId.serve` | `PhaseId.project` |
| Enum variant | `PhaseId.pipeline` | `PhaseId.compose` |
| Enum variant | `PhaseId.optimize` | `PhaseId.search` |
| Enum variant | `CoPhaseId` (Trace) | Mirror same renames |

Note: `Monad/Artifact/` dir name unchanged (class ArtifactRow→ArtifactMonad). `Monad/Error/`, `Monad/Store/` unchanged. `Comonad/Error/`, `Comonad/Store/`, `Comonad/Trace/` unchanged.

#### T6.7 — Stratum 7: IO + CoIO (8 source files + 8 JSON configs)

| Action | Old | New |
|--------|-----|-----|
| Dir rename (Types) | `IO/IOFeaturePhase/` | `IO/IOTransformPhase/` |
| Dir rename (Types) | `IO/IOTrainPhase/` | `IO/IOSolvePhase/` |
| Dir rename (Types) | `IO/IOServePhase/` | `IO/IOProjectPhase/` |
| Dir rename (Types) | `IO/IOMainPhase/` | `IO/IOComposePhase/` |
| Dir rename (CoTypes) | `CoIO/CoIOFeaturePhase/` | `CoIO/CoIOTransformPhase/` |
| Dir rename (CoTypes) | `CoIO/CoIOTrainPhase/` | `CoIO/CoIOSolvePhase/` |
| Dir rename (CoTypes) | `CoIO/CoIOServePhase/` | `CoIO/CoIOProjectPhase/` |
| Dir rename (CoTypes) | `CoIO/CoIOMainPhase/` | `CoIO/CoIOComposePhase/` |

Inside each executor/observer: update all import paths, class references, string literals referencing old names. Update all `default.json` field names to match new Hom/Dependent field names.

#### T6.8 — Cross-Cutting Updates

| Item | Action |
|------|--------|
| All `__init__.py` | Update import paths and `__all__` exports (if any) |
| All `default.json` (14 files) | Rename keys to match new field names |
| `justfile` | Rename commands: `cata-feature`→`cata-transform`, `cata-train`→`cata-solve`, `cata-serve`→`cata-project`, `hylo-main`→`hylo-compose`, `ana-feature`→`ana-transform`, `ana-train`→`ana-solve`, `ana-serve`→`ana-project`, `ana-main`→`ana-compose`. Update module paths in commands. |
| `pyproject.toml` | Version bump 0.3.0→0.4.0, add `dry-python/returns` dependency |

#### T6.9 — dry-python/returns Integration

| Item | Action |
|------|--------|
| Add dependency | `returns>=0.23` in `pyproject.toml` |
| IO executors (7) | Wrap `run()` return in `IOResult[T, ErrorMonad]` |
| StoreMonad lookups | Return `Maybe[ArtifactMonad]` |
| Pure fallible | `@safe` decorator, return `Result[T, ErrorMonad]` |
| IO fallible | `@impure_safe` decorator |
| Composition | `flow()` / `pipe()` for phase pipelines in IOComposePhase |

#### T6.10 — Verification

| Item | Action |
|------|--------|
| `rg` sweep | Grep for all old names across entire RL-Lab; fix any remaining references |
| `ruff check` | Lint pass |
| `pyright` | Type check pass |
| `just ana-check` | Full system health check (imports, field counts, JSON fidelity, roundtrip closure) |

### Execution Order

1. T6.1 through T6.7 (stratum by stratum, bottom-up)
2. T6.8 (cross-cutting: __init__.py, JSON, justfile, pyproject)
3. T6.9 (dry-python/returns integration)
4. T6.10 (verification sweep)
5. Single commit: `[Code | Refactor] v0.4.0: Execute taxonomic purification`

### Directory Rename Summary (Total: 52 git mv operations)

| Stratum | Types/ dirs | CoTypes/ dirs | Total |
|---------|:-----------:|:-------------:|:-----:|
| 1 Identity | 2 | 2 | 4 |
| 2 Inductive | 7 | 5 | 12 |
| 3 Dependent | 5 | 5 | 10 |
| 4 Hom | 4 | 4 | 8 |
| 5 Product | 4 | 4 | 8 |
| 6 Monad | 3 | 2 | 5 |
| 7 IO | 4 | 4 | 8 |
| **Total** | **29** | **26** | **55** |

### Session 6 Roadmap (T6)

| # | Task | Status |
|---|------|--------|
| T6.1 | Stratum 1 (Identity): dir + class renames | **DONE** (field `name`→`label` remains) |
| T6.2 | Stratum 2 (Inductive): dir + class renames | **DONE** (method renames `from_dataframe`→`from_io_frame` etc. remain) |
| T6.3 | Stratum 3 (Dependent): dir + class renames | **DONE** (field renames in Filter, Threshold, Search, Execution remain) |
| T6.4 | Stratum 4 (Hom): dir + class + field renames | **DONE** |
| T6.5 | Stratum 5 (Product): dir + class + status enum renames | **DONE** |
| T6.6 | Stratum 6 (Monad): dir + class + PhaseId variant renames | **DONE** |
| T6.7 | Stratum 7 (IO/CoIO): dir renames + internal ref updates | **DONE** |
| T6.8 | Cross-cutting: justfile, pyproject | **DONE** |
| T6.8b | Cross-cutting: remaining field/method renames + JSON configs | OPEN |
| T6.9 | dry-python/returns integration (dep added; wrapping not done) | OPEN |
| T6.10 | Verification sweep (rg, ruff, pyright, ana-check) | OPEN |

---

## 2026-03-09 — Session 5: Taxonomic Purification Spec + v0.4.0

### What happened
- Designed and documented a **complete taxonomic purification** -- every type name, phase name, and field name normalized from domain jargon to category-theoretic vocabulary.
- Phase chain renamed: `Discovery -> Ingest -> Feature -> Train -> Eval -> Serve -> Main` becomes `Discovery -> Ingest -> Transform -> Solve -> Eval -> Project -> Compose`.
- All type names, field names, and enum names normalized per root TEMPLATE.md Section 16 (Naming Normalization Protocol).
- Added root AGENTS.md invariants 33 (type-theoretic naming) and 34 (`dry-python/returns` monadic purity).
- Added root AGENTS.md anti-patterns for invariants 33 and 34.
- Integrated `dry-python/returns` monadic surface spec into all documentation: `IOResult[T, ErrorMonad]` for IO executors, `Result[T, ErrorMonad]` for pure fallible, `Maybe[T]` for store lookups, `@safe`/`@impure_safe` decorators, `flow()`/`pipe()` composition.
- Full rewrite of RL-Lab AGENTS.md, TEMPLATE.md, DICTIONARY.md, README.md with new taxonomy.
- Removed stale `INVENTORY-TYPES-HOM-DEPENDENT.md`.
- Updated all 14 per-stratum READMEs with new names.
- Updated root Universes README.md and TRACKER.md with version bump.

### Doc Changes

| File | What Changed |
|------|-------------|
| `Universes/AGENTS.md` | Added invariants 33 + 34, 2 new anti-patterns, count 31->34 |
| `Universes/TEMPLATE.md` | Section 16 (Naming Normalization Protocol) already present from prior edit |
| `Universes/README.md` | RL-Lab version bump v0.3.0 -> v0.4.0 |
| `Universes/TRACKER.md` | RL-Lab version bump, Naming Normalization Protocol in structures table |
| `RL-Lab/AGENTS.md` | Full rewrite with new taxonomy |
| `RL-Lab/TEMPLATE.md` | Full rewrite with new taxonomy + returns patterns |
| `RL-Lab/DICTIONARY.md` | Full rewrite with normalization table + new entries |
| `RL-Lab/README.md` | Full rewrite with new taxonomy |
| `RL-Lab/TRACKER.md` | Session 5 entry, T5.1-T5.4 roadmap |
| 14x per-stratum READMEs | Name propagation |

### Files Removed

| File | Reason |
|------|--------|
| `RL-Lab/INVENTORY-TYPES-HOM-DEPENDENT.md` | Superseded by DICTIONARY.md normalization table |

### Version
- v0.3.0 -> **v0.4.0** (docs-only; code rename deferred to next session)

### Session 5 Roadmap (T5)

| # | Task | Status |
|---|------|--------|
| T5.1 | Design complete rename mapping (all strata, all fields) | **DONE** |
| T5.2 | Document Naming Normalization Protocol (root TEMPLATE.md Section 16) | **DONE** |
| T5.3 | Update all RL-Lab docs with new taxonomy | **DONE** |
| T5.4 | Execute code renames (Python files, directories, imports, JSON) | DEFERRED → Session 6 (T6.1-T6.10) |

---

## 2026-03-09 — Session 4: Documentation Reconciliation + v0.3.0

### What happened
- Closed B17 (CoProduct stubs for Eval, Feature, Serve, Train -- all 7 phases now have real Output + Meta types).
- Added 7 per-stratum README.md files to CoTypes/ (CoIdentity, CoInductive, CoDependent, CoHom, CoProduct, Comonad, CoIO) with Lean 4 formal specs and validation checklists.
- Corrected stale field counts in CoHom README (5 types updated), CoProduct README (5 types updated), CoInductive README (1 type updated).
- Fixed CoInductive README naming: `CoAlgoIdentity` -> `CoAlgoInductive` (matches actual class name).
- Reconciled Morphism Surface against actual justfile: 4 former commands (ana-tail, ana-visualize, ana-render, ana-validate) dissolved into composite observers; ana-check reclassified from MISSING to DONE.
- Replaced all stale `ana-validate` references in AGENTS.md (2) and DICTIONARY.md (2) with `ana-main` / `ana-check`.
- Rewrote README.md Synopsis to match actual 15-command justfile surface.
- Created RL-Lab/TEMPLATE.md extending root Universes/TEMPLATE.md.
- Fixed justfile header comment (7 cata- -> 6 cata-).
- Bumped version to v0.3.0.

### Bug Status Changes

| Bug | Before | After | Evidence |
|-----|--------|-------|----------|
| B17 | OPEN | **CLOSED** | All 7 CoProduct phases have Output + Meta with real pydantic fields, proper TraceComonad imports |

### Doc Corrections

| File | What Changed |
|------|-------------|
| `CoTypes/CoHom/README.md` | Field counts: Feature 3->4, Train 3->4, Eval 4->5, Serve 3->5, Main 5->7 |
| `CoTypes/CoProduct/README.md` | Field counts: Ingest/Feature/Train/Serve Output 4->5, Main Output 5->7, Main Meta 3->7 |
| `CoTypes/CoInductive/README.md` | Field count: Screener 3->2. Naming: CoAlgoIdentity -> CoAlgoInductive |
| `AGENTS.md` | 2 stale `ana-validate` references -> `ana-check` / `ana-main` |
| `DICTIONARY.md` | 2 stale `ana-validate` references -> `ana-check` / `ana-main` |
| `README.md` | B17 closed. Synopsis rewritten (removed ana-validate, ana-render, duplicate ana-main; added ana-check). Competitive Positioning updated. |
| `justfile` | Header comment: 7 cata- -> 6 cata- |

### New Files

| File | Content |
|------|---------|
| `CoTypes/CoIdentity/README.md` | CoStratum 1 formal spec + validation checklist |
| `CoTypes/CoInductive/README.md` | CoStratum 2 formal spec + validation checklist |
| `CoTypes/CoDependent/README.md` | CoStratum 3 formal spec + validation checklist |
| `CoTypes/CoHom/README.md` | CoStratum 4 formal spec + validation checklist |
| `CoTypes/CoProduct/README.md` | CoStratum 5 formal spec + validation checklist |
| `CoTypes/Comonad/README.md` | CoStratum 6 formal spec + validation checklist |
| `CoTypes/CoIO/README.md` | CoStratum 7 formal spec + validation checklist |
| `TEMPLATE.md` | Lab-specific naming, phase chain, file extensions, IO/observer patterns |

---

## 2026-03-08d — Session 3: Type-Theoretic Purification (Parts 4-10)

### What happened
- Completed the 10-part refactor plan initiated in Session 2.
- Dissolved non-generating Hom types (PipelineHom, ServeInputHom) from all IO executors.
- Extracted ArtifactRow to its own file; replaced bare Literals with ADT enums.
- Created 4 Comonad observation witness duals.
- Purified all silent try/except blocks with typed ErrorMonad flows.
- Fixed 3 bugs: B5 (order fill verification), B12 (reward plateau detection), D8.10 (max drawdown circuit breaker).

### Changes by Part

| Part | Description | Files Changed |
|------|-------------|---------------|
| 4/5 | IOMainPhase purification — removed PipelineHom import, Settings from 7 to 6 fields, local Hom instantiation | `Types/IO/IOMainPhase/default.py`, `default.json` |
| 6a | Extract ArtifactRow to `Types/Monad/Artifact/default.py` | `Types/Monad/Store/default.py`, new `Types/Monad/Artifact/default.py` |
| 6b | Create AlarmSeverity ADT enum | new `Types/Inductive/AlarmSeverity/default.py`, `Types/Monad/Alarm/default.py`, `Types/IO/IODiscoveryPhase/default.py` |
| 6c | Create MetricKind ADT enum | new `Types/Inductive/MetricKind/default.py`, `Types/Monad/Metric/default.py` |
| 6d | Inline _Path/_Url type aliases | `Types/Monad/Store/default.py` |
| 6e | Add min_length=0 to TickerInfoInductive.symbol | `Types/Inductive/TickerInfo/default.py` |
| 7 | Create 4 Comonad duals | new `CoTypes/Comonad/{Error,Metric,Alarm,Store}/default.py` |
| 8 | Replace 6 silent try/except with ErrorMonad | `IODiscoveryPhase`, `IOMainPhase`, `IOServePhase` (3 fixes), `IOFeaturePhase` |
| 9a | B5 fix: order.status check | `Types/IO/IOServePhase/default.py` (4 occurrences) |
| 9b | B12 fix: reward plateau detection | `Types/IO/IOTrainPhase/default.py` |
| 9c | D8.10: max drawdown circuit breaker | `Types/Dependent/Risk/default.py`, `Types/IO/IOServePhase/default.py`, 3 default.json files |
| 10 | Docs update | `AGENTS.md`, `DICTIONARY.md`, `TRACKER.md`, `README.md` |

### Bug Status Changes

| Bug | Before | After | Fix |
|-----|--------|-------|-----|
| B5 | OPEN | **CLOSED** | `getattr(order, "status", None) == "filled"` replaces `hasattr(order, "filled_qty")` |
| B12 | OPEN | **CLOSED** | Reward plateau detection via tail std < 1e-4 sets `meta.early_stopped = True` |
| B14 | OPEN | **CLOSED** (dissolved) | IOTailPhase deleted — Tail absorbed into CoIOMainPhase |
| B15 | OPEN | **CLOSED** (dissolved) | IOVisualizePhase deleted — Visualize absorbed into CoIOMainPhase |
| D8.10 | OPEN | **CLOSED** | `max_drawdown_pct` field on RiskDependent; circuit breaker in IOServePhase serve loop |

### New Types Created

| Type | Location | Category | Fields |
|------|----------|----------|--------|
| ArtifactRow | `Types/Monad/Artifact/default.py` | Monad | 6 |
| AlarmSeverity | `Types/Inductive/AlarmSeverity/default.py` | Inductive | 3 variants |
| MetricKind | `Types/Inductive/MetricKind/default.py` | Inductive | 2 variants |
| CoErrorComonad | `CoTypes/Comonad/Error/default.py` | Comonad | 4 |
| CoMetricComonad | `CoTypes/Comonad/Metric/default.py` | Comonad | 4 |
| CoAlarmComonad | `CoTypes/Comonad/Alarm/default.py` | Comonad | 4 |
| CoStoreComonad | `CoTypes/Comonad/Store/default.py` | Comonad | 5 |

### Types Dissolved

| Type | Was At | Reason |
|------|--------|--------|
| PipelineHom | `Types/Hom/Pipeline/` | Non-generating — product of existing Hom types |
| ServeInputHom | `Types/Hom/ServeInput/` | Non-generating — product of existing Hom types |

### Directory Counts (Final)

| Directory | Count | Limit | Status |
|-----------|:-----:|:-----:|--------|
| Types/Identity | 2 | 7 | OK |
| Types/Inductive | **7** | 7 | At limit |
| Types/Dependent | 5 | 7 | OK |
| Types/Hom | **7** | 7 | At limit |
| Types/Product | **7** | 7 | At limit |
| Types/Monad | **6** | 7 | OK |
| Types/IO | **7** | 7 | At limit |
| CoTypes/CoIdentity | 2 | 7 | OK |
| CoTypes/CoInductive | 5 | 7 | OK |
| CoTypes/CoDependent | 5 | 7 | OK |
| CoTypes/CoHom | **7** | 7 | At limit |
| CoTypes/CoProduct | **7** | 7 | At limit |
| CoTypes/Comonad | **5** | 7 | OK |
| CoTypes/CoIO | **7** | 7 | At limit |

---

## 2026-03-08b — Implementation Verification (docs <-> code reconciliation)

### What happened
- Performed full filesystem audit against documentation written in 2026-03-08a entry.
- Discovered the codebase had advanced substantially beyond what docs described.
- Multiple items documented as OPEN/MISSING were already implemented.
- This entry corrects all drift between documentation and actual implementation.

### Drift Found and Corrected

| Item | Previous Doc Status | Actual Code Status | Corrected |
|------|--------------------|--------------------|-----------|
| B1 (CoHom imports broken) | OPEN | **FIXED** — CoHom/ has 9 subdirs, all populated | CLOSED |
| B2 (CoMonad/ naming, IO/ naming) | OPEN | **FIXED** — `Comonad/` and `CoIO/` correct | CLOSED |
| B7 (torch import) | OPEN | **FIXED** — torch is lazy in IOMainPhase `_run_pipeline` | CLOSED |
| B8 (Settings >7 fields) | OPEN | **FIXED** — decomposed via PipelineHom + ServeInputHom | CLOSED |
| B9 (discovery JSON missing alarms) | OPEN | **FIXED** — JSON keys match Settings | CLOSED |
| B10 (stale broker_mode in serve JSON) | OPEN | **FIXED** — JSON keys match Settings | CLOSED |
| CoIdentity/CoInductive/CoDependent | MISSING | **SCAFFOLDED** — all 3 categories populated with types | Updated |
| Per-phase CoHom duals | MISSING | **IMPLEMENTED** — 7 per-phase CoHom types | Updated |
| Per-phase CoProduct duals | MISSING | **PARTIALLY IMPLEMENTED** — Discovery, Ingest, Main have Output+Meta; Eval, Feature, Serve, Train are stubs | Updated |
| Per-phase CoIO observers | MISSING | **IMPLEMENTED** — 7 per-phase CoIO executors + JSON | Updated |
| Justfile prefixes | bare names | **RENAMED** — all 18 commands use ana-/cata-/hylo- | Updated |
| Validator location | Types/IO/Validate/ | **MOVED** to CoTypes/CoIO/CoIOValidatePhase/ | Updated |
| ServeInputHom (new) | not documented | **EXISTS** — Types/Hom/ServeInput/default.py (2 fields) | Added |

### New Issues Found

| ID | Severity | Summary | Status |
|----|----------|---------|--------|
| B14 | COSMETIC | `CoTypes/CoIO/IOTailPhase/` uses `IO` prefix, not `CoIO` prefix | **CLOSED** (dissolved) |
| B15 | COSMETIC | `CoTypes/CoIO/IOVisualizePhase/` uses `IO` prefix, not `CoIO` prefix | **CLOSED** (dissolved) |
| B16 | COSMETIC | Stale `Types/IO/Validate/default.py` superseded by CoIO version | **CLOSED** |

### New Issues Found (2026-03-08c verification)

| ID | Severity | Summary | Status |
|----|----------|---------|--------|
| B17 | GAP | `CoTypes/CoProduct/{Eval,Feature,Serve,Train}/` are stubs — only `__init__.py`, no Output/Meta | **CLOSED** |

### Current State Summary

| Half | Types Present | Types at Completion | Status |
|------|:------------:|:-------------------:|--------|
| Types/ (algebraic) | 49 | 49 | **COMPLETE** |
| CoTypes/ (coalgebraic) | ~51 | ~51 | **COMPLETE** |
| **Total** | **~100** | **~100** | **~100%** |

Types/ count updated from 47 to 49 (added PipelineHom, ServeInputHom).

---

## 2026-03-08c — Second Code Verification Pass

### What happened
- Verified all 7 remaining open bugs (B3-B6, B11-B13) against current source code.
- 5 of 7 were already FIXED in code. 2 remain open (B5, B12).
- B16 was already resolved (stale file removed).
- Discovered B17: 4 CoProduct phase directories are stubs (Eval, Feature, Serve, Train).
- Updated morphism count from 17 to 18 (ana-main was undercounted).

### Bug Verification Results

| Bug | Description | Previous Status | Verified Status | Evidence |
|-----|-------------|----------------|-----------------|----------|
| B3 | `_is_market_open()` UTC vs local time | OPEN | **FIXED** | IOServePhase:102-116 now converts via ZoneInfo per asset type |
| B4 | Eval results not persisted to store | OPEN | **FIXED** | IOEvalPhase:245-258 now calls `eval_store.put("eval", record)` |
| B5 | `orders_filled` without fill verification | OPEN | **STILL OPEN** | IOServePhase:166-225 checks `hasattr(order, "filled_qty")` but not actual fill status |
| B6 | Short positions silently ignored | OPEN | **FIXED** | IOServePhase:168-220 now handles negative target_pos with SELL orders |
| B11 | LiquidityDependent fields unused | OPEN | **FIXED** | IODiscoveryPhase:117-189 `_filter_by_liquidity()` uses all fields |
| B12 | `early_stopped` never set | OPEN | **STILL OPEN** | IOTrainPhase:140 `model.learn()` called without callback; field never assigned True |
| B13 | Data gaps detected but not handled | OPEN | **FIXED** | IOIngestPhase:118-135 now forward-fills all gaps, warns on large gaps (>5x interval) |
| B16 | Stale Validate file | OPEN | **FIXED** | `Types/IO/Validate/` no longer exists on filesystem |

---

## Bug Tracker (current)

| ID | Severity | Summary | Status |
|----|----------|---------|--------|
| B1 | BLOCKER | CoHom imports broken — files misplaced | **CLOSED** |
| B2 | BLOCKER | `CoMonad/` vs `Comonad/` casing; `CoTypes/IO/` vs `CoTypes/CoIO/` naming | **CLOSED** |
| B3 | BUG | `_is_market_open()` compares UTC to US Eastern trade hours | **CLOSED** |
| B4 | BUG | Eval results not persisted to StoreMonad | **CLOSED** |
| B5 | BUG | Broker `orders_filled` incremented without fill verification | **CLOSED** |
| B6 | BUG | Short positions silently ignored by broker execution | **CLOSED** |
| B7 | BUG | Top-level `import torch` in IOMainPhase crashes if torch missing | **CLOSED** |
| B8 | BUG | IOEvalPhase Settings 8 fields, IOMainPhase Settings 10 fields (>7 invariant) | **CLOSED** |
| B9 | COSMETIC | Discovery `default.json` missing `alarms` key | **CLOSED** |
| B10 | COSMETIC | Stale `broker_mode` in Serve `default.json` | **CLOSED** |
| B11 | GAP | `LiquidityDependent` fields declared but unused in IODiscoveryPhase | **CLOSED** |
| B12 | GAP | `TrainProductMeta.early_stopped` never set (no early stopping callback) | **CLOSED** |
| B13 | GAP | Data gaps detected but not handled (no forward-fill or gap-aware slicing) | **CLOSED** |
| B14 | COSMETIC | `CoTypes/CoIO/IOTailPhase/` uses `IO` prefix, not `CoIO` prefix | **CLOSED** (dissolved) |
| B15 | COSMETIC | `CoTypes/CoIO/IOVisualizePhase/` uses `IO` prefix, not `CoIO` prefix | **CLOSED** (dissolved) |
| B16 | COSMETIC | Stale `Types/IO/Validate/default.py` superseded by CoIO version | **CLOSED** |
| B17 | GAP | `CoTypes/CoProduct/{Eval,Feature,Serve,Train}/` are stubs (no Output/Meta) | **CLOSED** |

**Open: 0** (0 blocker, 0 bug, 0 gap, 0 cosmetic). **Closed: 17.**

---

## Root AGENTS.md Compliance

| # | Invariant | Status | Notes |
|---|-----------|--------|-------|
| 1 | Types/ + CoTypes/ only top-level source dirs | PASS | |
| 2 | 7 categories per side | PASS | All 7 CoTypes categories present |
| 3 | 1-1 CoTypes dual | PASS | Full 7-category duality |
| 4 | One type per file | PASS | Supporting enums co-located per lab policy |
| 5 | IO/ capped at 7 subdirs | PASS | Validator moved to CoTypes/CoIO/; Types/IO/ has exactly 7 |
| 6 | All filenames `default.*` | PASS | |
| 7 | No import-tree | PASS | IOMainPhase explicitly imports phases 1-6 |
| 8 | No options blocks in IO | PASS | |
| 9 | No nulls | PASS | Sentinels used consistently; zero nulls in all 16 JSON files |
| 10 | No vendor names in category/phase names | PASS | |
| 11 | No bare strings for finite variants | PASS | All finite sets are enums |
| 12 | Import DAG strictly layered | PASS | |
| 13 | Monad/IO terminal in DAG | PASS | |
| 14 | 1-1-1: Hom x Product x IO per phase | PASS | All 7 phases have the triple |
| 15 | <=7 phases, <=7 fields per type | PASS | All Settings <=7; several at exactly 7 |
| 16 | default.json committed | PASS | All 16 JSON boundaries present (7 Types + 9 CoTypes) |
| 17 | Justfile commands classified ana-/cata-/hylo- | PASS | 18 commands, all prefixed |
| 18 | Directory placement IS typing | PASS | |
| 19 | Every filetype has canonical category | PASS | |
| 20 | Testing = coalgebraic observation | PASS | Per-phase ana- observers implemented |
| 21 | 6-functor formalism classifies all morphisms | PASS | |
| 22 | Phase placement by type theory only | PASS | |
| 23 | Invariants never traded for convenience | PASS | |
| 24 | Docs first | PASS | |
| 25 | CoTypes/ is bidirectional path closure witness | PARTIAL | Per-phase observers exist; agreement check (path a == path b) not yet automated |
| 26 | Local override pattern (default.json + local.json) | NOT YET | No local.json pattern implemented |
| 27 | IO executor reads merge(base, local) | NOT YET | |
| 28 | Project boundary = artifact type | PASS | Single-asset RL pipeline |
| 29 | Fractal self-similarity | PASS | |
| 30 | Minimal orthogonal generating set | PASS | |
| 31 | Sub-projects with own type systems are separate labs | PASS | |

**Compliance: 26 PASS, 1 PARTIAL, 2 NOT YET, 0 FAIL**

---

## Finishing Roadmap (Revised)

### Tier 0 — Structural Integrity: **COMPLETE**

All 4 tasks done: B1 closed, B2 closed, B7 closed, B8 closed.

### Tier 1 — Production Correctness (cata- path must be trustworthy)

| # | Task | Bug | DoD | Status |
|---|------|-----|-----|--------|
| T1.1 | Market hours: asset-aware timezone in `_is_market_open()` | B3 | D6.11 | **DONE** |
| T1.2 | Persist eval results to StoreMonad | B4 | D5.9 | **DONE** |
| T1.3 | Broker fill verification before incrementing `orders_filled` | B5 | D6.13 | **DONE** |
| T1.4 | Short position handling in broker execution | B6 | D6.12 | **DONE** |
| T1.5 | Gap handling: forward-fill or warn when gaps exceed 2x interval | B13 | D1.6 | **DONE** |
| T1.6 | Max drawdown circuit breaker in IOServePhase | -- | D8.10 | **DONE** |
| T1.7 | Wire `early_stopped` callback in IOTrainPhase | B12 | -- | **DONE** |
| T1.8 | Wire `LiquidityDependent` fields in IODiscoveryPhase | B11 | -- | **DONE** |

### Tier 2 — Morphism Naming + JSON Fidelity: **COMPLETE**

Justfile renamed (T2.1 done). JSON fidelity verified clean across all 16 files (T2.2, T2.3 done).

### Tier 3 — CoTypes Completion: **COMPLETE**

| # | Task | Status |
|---|------|--------|
| T3.1 | Scaffold CoIdentity/, CoInductive/, CoDependent/ | **DONE** |
| T3.2 | Implement CoAssetIdentity, CoRunIdentity | **DONE** |
| T3.3 | Implement CoOHLCVInductive, CoScreenerInductive, CoAlgoInductive, CoTickerInfoInductive, CoScreenerQuoteInductive | **DONE** |
| T3.4 | Implement CoEnvDependent, CoRiskDependent, CoLiquidityDependent, CoAlarmDependent, CoOptimizeDependent | **DONE** |
| T3.5 | Implement per-phase CoHom duals (7 types) | **DONE** |
| T3.6 | Implement per-phase CoProduct duals (14 types) | **DONE** (all 7 phases have Output + Meta — B17 closed) |
| T3.7 | Implement per-phase ana- observer commands (7 CoIO executors) | **DONE** |
| T3.8 | Implement `ana-store` (list runs, artifacts, blob sizes) | OPEN |
| T3.9 | Implement `ana-check` (full system health: store, deps, imports) | **DONE** (delegates to CoIOMainPhase with all validation flags) |

### Tier 4 — Bidirectional Path Closure

| # | Task | Path | Status |
|---|------|------|--------|
| T4.1 | Schema observation: roundtrip closure for all Hom types | (a) | PARTIAL (validator section 11 covers some) |
| T4.2 | Runtime observation: per-phase CoIO observer -> CoProduct | (b) | **DONE** (all 7 per-phase observers exist) |
| T4.3 | Agreement check: path (a) and path (b) yield identical CoProduct | proof | OPEN |

### Cleanup Tasks

| # | Task | Bug |
|---|------|-----|
| C1 | ~~Rename `CoTypes/CoIO/IOTailPhase/` -> `CoIOTailPhase/`~~ | ~~B14~~ **DISSOLVED** — absorbed into CoIOMainPhase |
| C2 | ~~Rename `CoTypes/CoIO/IOVisualizePhase/` -> `CoIOVisualizePhase/`~~ | ~~B15~~ **DISSOLVED** — absorbed into CoIOMainPhase |
| C3 | ~~Remove stale `Types/IO/Validate/default.py`~~ | ~~B16~~ **CLOSED** |
| C4 | ~~Populate CoProduct stubs for Eval, Feature, Serve, Train (Output + Meta)~~ | ~~B17~~ **CLOSED** |

---

## Morphism Surface (Verified)

### cata- (Catamorphism / Production)

| Command | 6FF | IO Executor | Status |
|---------|-----|-------------|--------|
| `cata-discover` | f! shriek push | IODiscoveryPhase | **DONE** |
| `cata-ingest` | f! shriek push | IOIngestPhase | **DONE** |
| `cata-feature` | f! shriek push | IOFeaturePhase | **DONE** |
| `cata-train` | f! shriek push | IOTrainPhase | **DONE** |
| `cata-eval` | f! shriek push | IOEvalPhase | **DONE** |
| `cata-serve` | f! shriek push | IOServePhase | **DONE** |

### ana- (Anamorphism / Observation)

| Command | 6FF | What It Observes | Status |
|---------|-----|-----------------|--------|
| `ana-discover` | f* pullback | Last DiscoveryProductOutput from store | **DONE** |
| `ana-ingest` | f* pullback | Last IngestProductOutput | **DONE** |
| `ana-feature` | f* pullback | FeatureProductOutput geometry stats | **DONE** |
| `ana-train` | f* pullback | TrainProductOutput learning curves | **DONE** |
| `ana-eval` | f* pullback | EvalProductOutput return/drawdown (+ optional Flask renderer) | **DONE** |
| `ana-serve` | f* pullback | ServeProductOutput broker/audit | **DONE** |
| `ana-main` | f* pullback | MainProductOutput + type validation + optional Rerun viz | **DONE** |
| `ana-check` | f! shriek pullback | Cross-cutting: imports, field counts, JSON fidelity | **DONE** |
| `ana-store` | Hom internal | All runs, artifacts, blob sizes | MISSING |

### Dissolved (absorbed into composite observers)

| Former Command | Was | Absorbed Into | When |
|---------------|-----|---------------|------|
| `ana-tail` | SSE event stream observer | `ana-main` (CoIOMainPhase) | Session 3 |
| `ana-visualize` | Rerun multi-modal dashboard | `ana-main --main.visualize true` | Session 3 |
| `ana-render` | gym-trading-env Flask dashboard | `ana-eval --eval.launch_renderer true` | Session 3 |
| `ana-validate` | Type schemas + JSON roundtrip | `ana-main` / `ana-check` | Session 3 |

### hylo- (Hylomorphism / Composite)

| Command | 6FF | Composition | Status |
|---------|-----|-------------|--------|
| `hylo-main` | tensor | discover -> ingest -> feature -> train -> eval (walk-forward) | **DONE** |
| `hylo-optimize` | tensor | Optuna HPO wrapping train -> eval | **DONE** (inside `hylo-main --main.optimize true`) |

**Justfile surface: 15 commands (6 cata + 7 ana-phase + 1 ana-check + 1 hylo). All implemented.** 4 former commands dissolved into composite observers. 1 missing: `ana-store`.

---

## Definition of Done Status (Verified)

| Category | Total | Done | TODO | Partial |
|----------|:-----:|:----:|:----:|:-------:|
| D1. Data Pipeline | 8 | 8 | 0 | 0 |
| D2. Feature Engineering | 8 | 8 | 0 | 0 |
| D3. Environment Design | 7 | 7 | 0 | 0 |
| D4. Training Pipeline | 7 | 7 | 0 | 0 |
| D5. Evaluation | 9 | 9 | 0 | 0 |
| D6. Live Serving | 13 | 13 | 0 | 0 |
| D7. Optimization | 5 | 5 | 0 | 0 |
| D8. Production Safeguards | 10 | 10 | 0 | 0 |
| D9. Observability | 7 | 7 | 0 | 0 |
| D10. Type System Integrity | 15 | 15 | 0 | 0 |
| **Totals** | **89** | **89** | **0** | **0** |

**Completion: 89/89 (100%)**

### Remaining TODO Items

All DoD items complete. All bugs closed. Remaining non-DoD tasks: T3.8 (ana-store), T4.1/T4.3 (path closure).

---

## 2026-03-08a — Full Type-Theoretic Audit + Finishing Roadmap

### What happened
- Cross-referenced RL-Lab against root Universes AGENTS.md (31 invariants).
- Built tiered finishing roadmap from the synthetic homotopic geometry of the finished artifact.
- Classified all justfile commands as ana-/cata-/hylo- morphisms per root 6-functor formalism.
- Updated AGENTS.md with full 7-category CoTypes duality, justfile morphism section.
- Updated DICTIONARY.md with catamorphism/anamorphism/hylomorphism terms, 3 missing CoTypes categories, 6FF formalism terms.
- Updated README.md Definition of Done references.
- Added RL-Lab to root Universes TRACKER.md.

**Note:** This audit was performed against a stale view of the code. See 2026-03-08b for corrections.

---

## 2026-03-05 — Full Audit, README Rewrite, DICTIONARY + TRACKER Created

### What happened
- Performed full codebase audit comparing documentation against implementation.
- Researched FinRL (14k stars), TensorTrade (6k stars), gym-trading-env, and SB3 for sanity-checking.
- Rewrote README.md as the definitive system design with a **Definition of Done** checklist (D1-D10).
- Created DICTIONARY.md mapping every domain term to its type-theoretic placement.
- Created TRACKER.md (this file).

### Audit findings

**13 issues found** (2 BLOCKER, 8 BUG, 5 GAP/COSMETIC). 12 now closed. See Bug Tracker above for current status.

### Research comparison

Compared against the open-source RL trading ecosystem. This project implements several features that **no other framework provides**:
- Asset auto-discovery with ADX regime detection
- Model staleness and data freshness gates
- Graceful shutdown with position flattening
- Audit JSONL trail
- Typed artifact store (StoreMonad)
- Coalgebraic observer layer

**Gaps vs ecosystem:**
- No slippage modeling (none of the frameworks do this well either)
- No multi-asset simultaneous portfolio (by design — single-asset with rotation)
- No ensemble methods
- No early stopping callback (field exists, not wired)

---

## Pre-2026-03-05 — Initial Implementation

### v0.2.0 — CoTypes + Observers
- Added `CoTypes/` coalgebraic dual hierarchy
- Implemented `IOTailPhase` (SSE event stream observer)
- Implemented `IOVisualizePhase` (Rerun multi-modal dashboard)
- Added `TraceComonad` observation cursor
- Added `CoPhaseId` enum for observer identification
- Added `just tail` and `just visualize` to justfile
- Added `sseclient-py` and `rerun-sdk` dependencies

### v0.1.0 — Core Pipeline
- Implemented all 7 phases: Discovery, Ingest, Feature, Train, Eval, Serve, Main
- Established matter-phase type system (7 layers: Identity through IO)
- Created `StoreMonad` with SQLite artifact DB + blob filesystem
- Created `ObservabilityMonad` composable into all ProductMeta types
- Implemented walk-forward batch evaluation in IOMainPhase
- Implemented Optuna hyperparameter optimization
- Implemented Alpaca broker integration (paper/live)
- Implemented production safeguards in IOServePhase
- Created `justfile` as single interface (7 phases + render)
- Wrote AGENTS.md design invariants document
