# DICTIONARY.md -- Domain Term Reference

Every domain-specific term in this codebase mapped to its type-theoretic phase,
matter state, directory location, and definition.

**Read this file when encountering an unfamiliar term. Update it when adding new terms.**

---

## Type-Theoretic Phases (Quick Reference)

| # | Phase | Type Theory | Matter | Directory | Suffix |
|---|-------|-------------|--------|-----------|--------|
| 1 | Identity | Unit (top) | BEC | `Types/Identity/` | `{Domain}Identity` |
| 2 | Inductive | ADT / Sum | Crystalline | `Types/Inductive/` | `{Domain}Inductive` |
| 3 | Dependent | Indexed | Liquid Crystal | `Types/Dependent/` | `{Domain}Dependent` |
| 4 | Hom | Function | Liquid | `Types/Hom/` | `{Domain}Hom` |
| 5 | Product | Sum/Product | Gas | `Types/Product/` | `{Domain}Product{Kind}` |
| 6 | Monad | Effect | Plasma | `Types/Monad/` | `{Domain}Monad` |
| 7 | IO | IO | QGP | `Types/IO/` | `IO{Phase}Phase` |

CoTypes (dual -- 1-1 correspondence, no exceptions):

| # | Phase | Directory | Suffix | Dual of |
|---|-------|-----------|--------|---------|
| 1 | CoIdentity | `CoTypes/CoIdentity/` | `Co{Domain}Identity` | Identity |
| 2 | CoInductive | `CoTypes/CoInductive/` | `Co{Domain}Inductive` | Inductive |
| 3 | CoDependent | `CoTypes/CoDependent/` | `Co{Domain}Dependent` | Dependent |
| 4 | CoHom | `CoTypes/CoHom/` | `Co{Phase}Hom` | Hom |
| 5 | CoProduct | `CoTypes/CoProduct/` | `Co{Phase}Product{Kind}` | Product |
| 6 | Comonad | `CoTypes/Comonad/` | `{Domain}Comonad` | Monad |
| 7 | CoIO | `CoTypes/CoIO/` | `CoIO{Phase}Phase` | IO |

---

## Naming Normalization Table

Complete mapping from old (domain jargon) to new (category-theoretic vocabulary). See root TEMPLATE.md Section 16 for the universal protocol.

### Phase Chain

| Old | New | Rationale |
|-----|-----|-----------|
| Feature | Transform | The operation is a geometric transformation, not "feature engineering" |
| Train | Solve | The operation solves an optimization problem, not "training" |
| Serve | Project | The operation projects a learned morphism onto live data, not "serving" |
| Main | Compose | The operation composes all phases, not "main" |

### Type Names

| Old | New | Stratum |
|-----|-----|---------|
| `AssetIdentity` | `IndexIdentity` | 1 Identity |
| `RunIdentity` | `SessionIdentity` | 1 Identity |
| `AlgoIdentity` | `SolverInductive` | 2 Inductive |
| `AlarmSeverity` | `SeverityInductive` | 2 Inductive |
| `MetricKind` | `MeasureInductive` | 2 Inductive |
| `OHLCVInductive` | `FrameInductive` | 2 Inductive |
| `ScreenerInductive` | `CatalogInductive` | 2 Inductive |
| `ScreenerQuoteInductive` | `CatalogEntryInductive` | 2 Inductive |
| `TickerInfoInductive` | `IndexMetaInductive` | 2 Inductive |
| `EnvDependent` | `ExecutionDependent` | 3 Dependent |
| `RiskDependent` | `ConstraintDependent` | 3 Dependent |
| `LiquidityDependent` | `FilterDependent` | 3 Dependent |
| `AlarmDependent` | `ThresholdDependent` | 3 Dependent |
| `OptimizeDependent` | `SearchDependent` | 3 Dependent |
| `FeatureHom` | `TransformHom` | 4 Hom |
| `TrainHom` | `SolveHom` | 4 Hom |
| `ServeHom` | `ProjectHom` | 4 Hom |
| `MainHom` | `ComposeHom` | 4 Hom |
| `FeatureProductOutput` | `TransformProductOutput` | 5 Product |
| `TrainProductOutput` | `SolveProductOutput` | 5 Product |
| `ServeProductOutput` | `ProjectProductOutput` | 5 Product |
| `MainProductOutput` | `ComposeProductOutput` | 5 Product |
| `MainStatus` | `ComposeStatus` | 5 Product |
| `ServeStatus` | `ProjectStatus` | 5 Product |
| `AlarmMonad` | `SignalMonad` | 6 Monad |
| `MetricMonad` | `MeasureMonad` | 6 Monad |
| `ObservabilityMonad` | `EffectMonad` | 6 Monad |
| `ArtifactRow` | `ArtifactMonad` | 6 Monad |
| `IOFeaturePhase` | `IOTransformPhase` | 7 IO |
| `IOTrainPhase` | `IOSolvePhase` | 7 IO |
| `IOServePhase` | `IOProjectPhase` | 7 IO |
| `IOMainPhase` | `IOComposePhase` | 7 IO |

### Field Names

| Old | New | Rationale |
|-----|-----|-----------|
| `run_id` | `session_id` | Bounded execution context with identity |
| `run_ts` | `session_ts` | Temporal coordinate of the session |
| `asset_type` | `index_class` | The asset is an index; type is a class |
| `algo` | `solver` | Algorithm is a solver |
| `n_envs` | `n_parallel` | Parallel instances |
| `total_timesteps` | `budget` | Bounded resource allocation |
| `episode_duration_min` | `horizon_min` | Planning horizon |
| `normalize_obs` | `normalize_input` | Input normalization |
| `normalize_reward` | `normalize_signal` | Signal normalization |
| `train_run_id` | `solve_session_id` | Reference to solve session |
| `optimize` | `search` | Hyperparameter search |
| `optimize_config` | `search_fiber` | Dependent fiber for search |
| `broker_mode` | `execution_mode` | Execution mode (sim/paper/live) |
| `io_broker_key` | `io_execution_key` | IO-boundary execution backend key |
| `wavelet` | `basis` | Basis function family |
| `supertrend_period` | `envelope_period` | Price envelope period |
| `supertrend_multiplier` | `envelope_multiplier` | Envelope width multiplier |
| `adx_period` | `trend_period` | Trend strength period |
| `io_universe` | `io_indices` | Collection of indices |
| `screener` | `catalog_source` | Source producing a catalog |
| `min_adx` | `min_trend_score` | Minimum trend strength score |
| `min_bars` | `min_frame_length` | Minimum frame data length |
| `adx_lookback_period` | `trend_lookback` | Trend lookback window |
| `warmup_bars` | `warmup_frames` | Warmup frame count |
| `train_split_pct` | `solve_split_pct` | Solve split percentage |
| `io_algo` | `io_solver` | IO-boundary solver identifier |
| `poll_interval_s` | `sample_interval_s` | Sample polling interval |
| `max_bars` | `max_frames` | Maximum frames |
| `max_model_age_min` | `max_artifact_age_min` | Maximum artifact age |
| `forward_steps_min` | `horizon_min` | Evaluation horizon |

### Enum / Nested ADT Names

| Old | New | Location |
|-----|-----|----------|
| `AssetType` | `IndexClass` | Identity (nested) |
| `HolidayCalendar` | `TemporalMask` | Identity (nested) |
| `BrokerMode` | `ExecutionMode` | Dependent (nested) |
| `WaveletName` | `BasisInductive` | Hom (nested) |
| `MainStatus` | `ComposeStatus` | Product (nested) |
| `ServeStatus` | `ProjectStatus` | Product (nested) |

---

## A -- Index and Solver Terms

### ArtifactMonad
- **What:** Single row returned from StoreMonad queries. Represents one stored artifact.
- **Where:** `Types/Monad/Artifact/default.py`
- **Phase:** Monad (Plasma) -- extracted from StoreMonad per 1-type-per-file invariant.
- **Fields:** session_id, phase, artifact_type, blob_path, metadata_json, created_at

### BasisInductive
- **What:** 5-variant enum: db4, db6, db8, sym4, sym6. Basis function family selection for signal denoising.
- **Where:** `Types/Hom/Transform/default.py` (supporting enum)
- **Phase:** Hom (Liquid)

---

## C -- Catamorphism, CoTypes, and Category Terms

### Catamorphism (cata-)
- **What:** The unique algebra homomorphism from an initial algebra to any other algebra. Recursion scheme: fold. Consumes structure inward (leaves -> root).
- **Domain:** `cata-*` justfile commands. Production operations that fold typed specifications into artifacts. `cata-solve` folds SolveHom into a solved model.
- **Prefix:** `cata-` (justfile)
- **6FF:** f* (pushforward), f! (shriek push)

### Anamorphism (ana-)
- **What:** The unique coalgebra homomorphism from any coalgebra to a terminal coalgebra. Recursion scheme: unfold. Generates structure outward (seed -> leaves).
- **Domain:** `ana-*` justfile commands. Observation operations that unfold artifact state into typed evidence. `ana-eval` unfolds the last EvalProductOutput from the store.
- **Prefix:** `ana-` (justfile)
- **6FF:** f* (pullback), f! (shriek pullback), Hom (internal)

### Hylomorphism (hylo-)
- **What:** Composition of an anamorphism followed by a catamorphism: `cata . ana`. Unfold then fold. No intermediate data structure is materialized.
- **Domain:** `hylo-*` justfile commands. Composite operations: observe then produce. `hylo-compose` = validate then run full pipeline.
- **Prefix:** `hylo-` (justfile)
- **6FF:** tensor (x)

### CatalogInductive
- **What:** Validated catalog of market indices from a screener source. Wraps external API response into typed Inductive form.
- **Where:** `Types/Inductive/Catalog/default.py`
- **Phase:** Inductive (Crystalline) -- structural validation of external data.
- **Fields:** entries, indices()

### CatalogEntryInductive
- **What:** Single entry in a catalog -- one index with its metadata.
- **Where:** `Types/Inductive/CatalogEntry/default.py`
- **Phase:** Inductive (Crystalline)
- **Fields:** index_symbol, ...

### ComposeHom
- **What:** Compose phase input -- walk-forward windowing + search configuration.
- **Where:** `Types/Hom/Compose/default.py`
- **Phase:** Hom (Liquid)
- **Fields:** stride_min, solve_split_pct, search, search_fiber

### ComposeStatus
- **What:** Enum for compose phase completion status.
- **Where:** `Types/Product/Compose/Output/default.py` (supporting enum)
- **Phase:** Product (Gas)

### ConstraintDependent
- **What:** Per-step constraint parameters -- stop-loss, take-profit, and max drawdown thresholds.
- **Where:** `Types/Dependent/Constraint/default.py`
- **Phase:** Dependent (Liquid Crystal)
- **Fields:** stop_loss_pct (negative, e.g. -2.0), profit_threshold_pct (positive, e.g. 0.5), max_drawdown_pct (negative, e.g. -5.0)

### CoIdentity
- **What:** Coalgebraic dual of Identity. Coterminal introspection witnesses -- probes that answer: is this terminal object present? reachable? valid?
- **Where:** `CoTypes/CoIdentity/`
- **Instances:** `CoIndexIdentity` (Index/), `CoSessionIdentity` (Session/)
- **Dual of:** `Types/Identity/`

### CoInductive
- **What:** Coalgebraic dual of Inductive. Elimination forms -- parsers, validators, exhaustiveness witnesses for each ADT.
- **Where:** `CoTypes/CoInductive/`
- **Instances:** `CoFrameInductive` (Frame/), `CoCatalogInductive` (Catalog/), `CoSolverInductive` (Solver/), `CoIndexMetaInductive` (IndexMeta/), `CoCatalogEntryInductive` (CatalogEntry/)
- **Dual of:** `Types/Inductive/`

### CoDependent
- **What:** Coalgebraic dual of Dependent. Lifting property / cofibration -- schema conformance validators.
- **Where:** `CoTypes/CoDependent/`
- **Instances:** `CoExecutionDependent` (Execution/), `CoConstraintDependent` (Constraint/), `CoFilterDependent` (Filter/), `CoThresholdDependent` (Threshold/), `CoSearchDependent` (Search/)
- **Dual of:** `Types/Dependent/`

### CoHom
- **What:** Coalgebraic dual of Hom. Observer input configurations -- observation specifications that define what to check per phase.
- **Where:** `CoTypes/CoHom/`
- **Instances (per-phase):** CoDiscoveryHom, CoIngestHom, CoTransformHom, CoSolveHom, CoEvalHom, CoProjectHom, CoComposeHom

### CoPhaseId
- **What:** 7-variant enum identifying observer executors -- one per canonical phase. Distinct from PhaseId.
- **Where:** `CoTypes/Comonad/Trace/default.py`
- **Phase:** Comonad
- **Variants:** discovery, ingest, transform, solve, eval, project, compose

### CoProduct
- **What:** Coalgebraic dual of Product. Observer outputs + meta -- what an observer saw.
- **Where:** `CoTypes/CoProduct/`
- **Instances (per-phase):** CoDiscoveryProductOutput, CoIngestProductOutput, CoTransformProductOutput, CoSolveProductOutput, CoEvalProductOutput, CoProjectProductOutput, CoComposeProductOutput

### Comonad
- **What:** Coalgebraic dual of Monad. Observation witness types. `extract` gives the current observation. `extend` maps over observation history.
- **Where:** `CoTypes/Comonad/`
- **Instances:** TraceComonad, CoErrorComonad, CoMeasureComonad, CoSignalComonad, CoStoreComonad

### CoIO
- **What:** Coalgebraic dual of IO. Observer executors -- probes that read from the external world without modifying it.
- **Where:** `CoTypes/CoIO/`
- **Instances (per-phase):** CoIODiscoveryPhase, CoIOIngestPhase, CoIOTransformPhase, CoIOSolvePhase, CoIOEvalPhase, CoIOProjectPhase, CoIOComposePhase

---

## D -- Data and Dependent Terms

### default.json
- **What:** Committed JSON config file for each IO executor. The IO boundary -- equivalent to a lock file.
- **Where:** Every `Types/IO/IO{X}Phase/` and `CoTypes/CoIO/CoIO{X}Phase/` directory.
- **Invariant:** Must be faithful serialization of the Settings type. Regenerate via `just ana-check`.

### dry-python/returns
- **What:** Python library providing monadic containers for typed effect handling. The projection of monadic purity from the Lean type core to the Python IO layer.
- **Containers:** `Result[T, E]`, `IOResult[T, E]`, `Maybe[T]`, `IO[T]`, `RequiresContext[T, Deps]`
- **Decorators:** `@safe` (pure exception capture), `@impure_safe` (IO exception capture)
- **Composition:** `flow()`, `pipe()` for sequential composition
- **Phase:** IO (stratum 7) -- monadic surface for all Python IO executors
- **Invariant:** Root AGENTS.md invariant 34. Every IO executor returns `IOResult[T, ErrorMonad]`.

---

## E -- Execution and Eval Terms

### EffectMonad
- **What:** Free effect structure composed into every ProductMeta. Collects errors, measures, signals, timing.
- **Where:** `Types/Monad/Effect/default.py`
- **Phase:** Monad (Plasma)
- **Fields:** errors, measures, signals, phase, duration_s, started_at, completed_at

### EvalHom
- **What:** Eval phase input -- configures the evaluation horizon length.
- **Where:** `Types/Hom/Eval/default.py`
- **Phase:** Hom (Liquid)
- **Fields:** horizon_min

### EvalProductOutput / EvalProductMeta
- **What:** Eval phase output -- portfolio return, final value, threshold status, constraint gate triggers.
- **Where:** `Types/Product/Eval/Output/default.py`, `Types/Product/Eval/Meta/default.py`
- **Phase:** Product (Gas)

### ExecutionDependent
- **What:** Parameterized execution environment configuration shared across Solve, Eval, and Project.
- **Where:** `Types/Dependent/Execution/default.py`
- **Phase:** Dependent (Liquid Crystal)
- **Fields:** initial_value, fees_pct, borrow_rate_pct, position_space, execution_mode, io_execution_key

### ExecutionMode
- **What:** 3-variant enum: sim (backtest only), paper (Alpaca paper trading), live (Alpaca live trading).
- **Where:** `Types/Dependent/Execution/default.py` (supporting enum)
- **Phase:** Dependent (Liquid Crystal)

---

## F -- Filter and Frame Terms

### FilterDependent
- **What:** Relative (quantile-based) filter parameters for asset-agnostic discovery.
- **Where:** `Types/Dependent/Filter/default.py`
- **Phase:** Dependent (Liquid Crystal)
- **Fields:** volume_quantile, price_quantile, volatility_bound, turnover_quantile, require_invertible, enabled, min_catalog_size

### FrameInductive
- **What:** Structural validation schema for tabular market data (OHLCV frames). Wraps external DataFrame data into typed Inductive form.
- **Where:** `Types/Inductive/Frame/default.py`
- **Phase:** Inductive (Crystalline)
- **Methods:** from_io_frame(), to_io_frame()

### feature_ prefix
- **What:** All engineered feature columns are prefixed `feature_`. Enforced by regex `^feature_[a-z_]+$`.
- **Where:** `TransformProductOutput.feature_names` constraint
- **Phase:** Product (Gas)

---

## G -- Gym Terms

### gym-trading-env
- **What:** Third-party Gymnasium-compatible trading environment. Provides the observation space, action space, and default log-return reward.
- **Where:** Used in IOSolvePhase, IOEvalPhase, IOProjectPhase.
- **Invariant:** Default reward is never overridden. Stop-loss/take-profit are external checks, not reward shaping.

---

## H -- Hom Terms

### Hom
- **What:** Phase input type. Morphisms flowing INTO a phase. Named after Hom-sets in category theory.
- **Where:** `Types/Hom/`
- **Instances:** DiscoveryHom, IngestHom, TransformHom, SolveHom, EvalHom, ProjectHom, ComposeHom
- **Phase:** Liquid (state 4)

---

## I -- Identity and Inductive Terms

### Identity (type phase)
- **What:** Terminal objects with exactly one canonical inhabitant. Shared fixed points.
- **Where:** `Types/Identity/`
- **Instances:** IndexIdentity, SessionIdentity
- **Matter:** BEC (Bose-Einstein Condensate) -- coldest, most fundamental.

### IndexIdentity
- **What:** Terminal object defining a single tradeable index: index symbol, bar interval, trade hours, temporal mask.
- **Where:** `Types/Identity/Index/default.py`
- **Phase:** Identity (BEC) -- exactly one canonical configuration per index.
- **Fields:** index_class, io_ticker, interval_min, trade_start_min, trade_end_min, holidays

### IndexClass
- **What:** 3-variant enum: stock, crypto, forex. Determines index class routing in Discovery.
- **Where:** `Types/Identity/Index/default.py` (supporting enum)
- **Phase:** Identity (BEC)

### IndexMetaInductive
- **What:** Validated metadata for a single market index from external API.
- **Where:** `Types/Inductive/IndexMeta/default.py`
- **Phase:** Inductive (Crystalline)
- **Fields:** index_symbol, mean_volume, spot_price, session_high, session_low, capitalization

### Inductive (type phase)
- **What:** Sum types / ADTs. Structural validation schemas, finite enums, external data wrappers.
- **Where:** `Types/Inductive/`
- **Instances:** FrameInductive, CatalogInductive, CatalogEntryInductive, IndexMetaInductive, SolverInductive, SeverityInductive, MeasureInductive
- **Matter:** Crystalline -- rigid structure, validates shape.

### io_ prefix
- **What:** Convention for fields that cross the IO boundary (external inputs/outputs). e.g., `io_ticker`, `io_indices`, `io_execution_key`.
- **Rule:** Fields prefixed `io_` are external-facing. They come from outside the system.

---

## M -- Monad and Measure Terms

### MeasureInductive
- **What:** 2-variant enum for measurement kinds: counter, gauge.
- **Where:** `Types/Inductive/Measure/default.py`
- **Phase:** Inductive (Crystalline) -- exhaustively checkable ADT replacing bare Literal.

### MeasureMonad
- **What:** Single measure observation point -- name, value, kind (counter or gauge).
- **Where:** `Types/Monad/Measure/default.py`
- **Phase:** Monad (Plasma)

### Monad (type phase)
- **What:** Effect record types. What happened during execution -- errors, measures, signals, store operations.
- **Where:** `Types/Monad/`
- **Instances:** ErrorMonad, MeasureMonad, SignalMonad, EffectMonad, StoreMonad, ArtifactMonad
- **Matter:** Plasma -- hot, effectful.

---

## P -- Product and Phase Terms

### PhaseId
- **What:** 8-variant enum identifying pipeline phases: discovery, ingest, transform, solve, eval, project, compose, search.
- **Where:** `Types/Monad/Error/default.py`
- **Phase:** Monad (Plasma) -- supporting enum for ErrorMonad.

### Product (type phase)
- **What:** Phase outputs + meta. Computed results expanding outward from a phase.
- **Where:** `Types/Product/`
- **Structure:** `{Phase}/Output/default.py` + `{Phase}/Meta/default.py` for each of 7 phases.
- **Matter:** Gas -- expanding, observable.

### ProjectHom
- **What:** Project phase input -- which model to project, polling cadence, session limits, staleness gate.
- **Where:** `Types/Hom/Project/default.py`
- **Phase:** Hom (Liquid)
- **Fields:** solve_session_id, io_solver, sample_interval_s, max_frames, max_artifact_age_min

### ProjectStatus
- **What:** Enum for project phase completion status.
- **Where:** `Types/Product/Project/Output/default.py` (supporting enum)
- **Phase:** Product (Gas)

---

## S -- Session, Solver, Signal, Store, and Search Terms

### SearchDependent
- **What:** Optuna hyperparameter search configuration -- trial budget, parallelism, search space bounds.
- **Where:** `Types/Dependent/Search/default.py`
- **Phase:** Dependent (Liquid Crystal)

### SessionIdentity
- **What:** Terminal object defining a single pipeline session: ID, timestamp, seed, label, store, verbosity.
- **Where:** `Types/Identity/Session/default.py`
- **Phase:** Identity (BEC)
- **Fields:** session_id (8-char hex), session_ts (YYYYMMDD-HHMM), seed, label, store, verbose

### session_id
- **What:** 8-character hex string uniquely identifying a pipeline session. Auto-generated from UUID prefix.
- **Pattern:** `^[a-f0-9]{8}$`
- **Scope:** Keys all artifact storage, blob paths, and audit logs.

### SeverityInductive
- **What:** 3-variant enum for signal severity levels: info, warn, critical.
- **Where:** `Types/Inductive/Severity/default.py`
- **Phase:** Inductive (Crystalline) -- exhaustively checkable ADT replacing bare Literal.

### SignalMonad
- **What:** Threshold-triggered signal with severity. Dual of the alarm concept, typed as a monadic effect.
- **Where:** `Types/Monad/Signal/default.py`
- **Phase:** Monad (Plasma)

### SolveHom
- **What:** Solve phase input -- solver, parallelism, learning rate, budget, normalization flags.
- **Where:** `Types/Hom/Solve/default.py`
- **Phase:** Hom (Liquid)
- **Fields:** solver, n_parallel, learning_rate, budget, horizon_min, normalize_input, normalize_signal

### SolverInductive
- **What:** 4-variant enum for RL solver selection: PPO, SAC, DQN, A2C.
- **Where:** `Types/Inductive/Solver/default.py`
- **Phase:** Inductive (Crystalline) -- it is a finite sum type (ADT).

### StoreMonad
- **What:** Typed artifact store binding SQLite metadata to filesystem blobs. The IO boundary.
- **Where:** `Types/Monad/Store/default.py`
- **Phase:** Monad (Plasma)
- **Fields:** db_url, blob_dir, session_id, phase, docs_dir
- **Operations:** put(), get(), latest(), all_runs(), blob_path_for()
- **Monadic surface:** Store lookups return `Maybe[ArtifactMonad]` via `dry-python/returns`.

---

## T -- Transform and Trace Terms

### TemporalMask
- **What:** 3-variant enum: none, us_market, bank. Determines which days to skip.
- **Where:** `Types/Identity/Index/default.py` (supporting enum)
- **Phase:** Identity (BEC)

### ThresholdDependent
- **What:** Threshold configuration for signal evaluation.
- **Where:** `Types/Dependent/Threshold/default.py`
- **Phase:** Dependent (Liquid Crystal)

### TraceComonad
- **What:** Coalgebraic observation cursor -- tracks where an observer is in the event/artifact stream.
- **Where:** `CoTypes/Comonad/Trace/default.py`
- **Phase:** Comonad (dual of Monad)
- **Fields:** observer_id, cursor, events_seen, connection_ok, last_seen_at

### TransformHom
- **What:** Transform phase input -- basis function params, indicator params, regime threshold.
- **Where:** `Types/Hom/Transform/default.py`
- **Phase:** Hom (Liquid)
- **Fields:** basis, level, threshold_mode, trend_period, envelope_period, envelope_multiplier, regime_threshold

---

## V -- VecNormalize Terms

### VecNormalize
- **What:** SB3 wrapper that normalizes inputs and signals using running statistics. The only enhancement layer between raw gym env and the RL agent.
- **Where:** IOSolvePhase (wraps env), IOEvalPhase (loads saved stats), IOProjectPhase (loads saved stats).
- **Invariant:** This is the single normalization layer. No other input/signal transformations are applied.

---

## 6 -- 6-Functor Formalism and Formal Terms

### 6-Functor Formalism
- **What:** Grothendieck's six operations on sheaves: f* -| f* (pullback/pushforward), f! -| f! (shriek), x -| Hom (tensor/internal hom). Three adjoint pairs classifying all morphisms.
- **Domain:** Every justfile recipe is classified by one of the six functors. `ana-*` uses f* (pullback), f! (shriek pullback), Hom (internal). `cata-*` uses f* (pushforward), f! (shriek push). `hylo-*` uses x (tensor product).

### Bidirectional Path Closure
- **What:** Agreement between two observation paths to the same codomain. Path (a) destructures the typed output (schema observation). Path (b) probes the live artifact (runtime observation). Both yield CoProduct. If they agree, the path is closed.
- **Domain:** CoTypes/ is the bidirectional path closure witness. Path (a): `Hom -> toJson -> fromJson -> Hom` roundtrip (validated by `ana-compose` / `ana-check`). Path (b): `Product -> CoIO observer -> CoProduct` (validated by per-phase `ana-{phase}` commands). Agreement = correctness.

### Free-Forgetful Adjunction (F -| U)
- **What:** The relationship between production and observation. F (free, left adjoint) is the production path: Types/ -> IO -> Product. U (forgetful, right adjoint) is the observation path: Product -> CoIO -> CoProduct. The unit n = toJson, the counit e = fromJson. Roundtrip closure (fromJson . toJson = id) is the adjunction identity.
- **Domain:** The system is well-typed when what you build (F) is what you observe (U), modulo the forgotten construction path.

### Profunctor
- **What:** A bifunctor P : C^op x D -> Set, contravariant in the first argument (inputs), covariant in the second (outputs).
- **Domain:** Every phase is a profunctor. Hom/ is the contravariant leg (domain), Product/ is the covariant leg (codomain), and the IO executor is the effectful arrow between them. Pattern: `Hom(phase) --IO executor--> Product(phase)`.
