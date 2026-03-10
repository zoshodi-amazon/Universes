# RL Trading Sandbox

Autonomous self-hosted quant RL lab. Asset-agnostic (stocks, crypto, forex).

## Synopsis

```
# cata- (Catamorphism) -- production, Types/ -> Artifact
just cata-discover       # Phase 1 (BEC): Find trending indices
just cata-ingest         # Phase 2 (Crystalline): Download frame data
just cata-transform      # Phase 3 (Liquid Crystal): Basis denoise + indicators
just cata-solve          # Phase 4 (Liquid): RL model solving
just cata-eval           # Phase 5 (Gas): Out-of-sample evaluation
just cata-project        # Phase 6 (Plasma): Live projection with execution

# ana- (Anamorphism) -- observation, Artifact -> CoTypes/
just ana-discover        # Observe last DiscoveryProductOutput from store
just ana-ingest          # Observe last IngestProductOutput
just ana-transform       # Observe TransformProductOutput geometry stats
just ana-solve           # Observe SolveProductOutput learning curves
just ana-eval            # Observe EvalProductOutput return/drawdown
just ana-project         # Observe ProjectProductOutput execution/audit
just ana-compose         # Observe ComposeProductOutput + type validation + optional Rerun viz
just ana-check           # Cross-cutting: imports, field counts, JSON fidelity

# hylo- (Hylomorphism) -- composite, ana then cata
just hylo-compose        # Phase 7 (QGP): Full pipeline
```

## Definition of Done

The system is complete when every item below is implemented, tested, and documented.
Each item maps to a checklist entry. No item may be removed. Items may only be added.

### D1. Data Pipeline

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D1.1 | Multi-source frame ingestion (yfinance + Alpaca) | DONE | Ingest |
| D1.2 | Frame schema validation via `FrameInductive.from_io_frame()` -- no raw dicts cross IO boundary | DONE | Ingest |
| D1.3 | Pickle caching under `store/blobs/cache/` with cache-hit tracking | DONE | Ingest |
| D1.4 | Data freshness gate -- reject data older than 7 days in Project | DONE | Project |
| D1.5 | Temporal gap detection -- `data_gaps_count` recorded in `IngestProductMeta` | DONE | Ingest |
| D1.6 | Temporal gap handling -- forward-fill or warn when gaps exceed 2x expected interval | DONE | Ingest |
| D1.7 | Walk-forward temporal splits -- no lookahead leakage via `IOComposePhase` windowing | DONE | Compose |
| D1.8 | Index-agnostic support -- stocks, crypto, forex via `IndexIdentity` routing | DONE | Discovery |

### D2. Transform Engineering

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D2.1 | Basis (db4) denoising on all 5 frame channels -- denoised_pct, approx_pct, detail_energy | DONE | Transform |
| D2.2 | Trend indicator normalized to [0, 1] | DONE | Transform |
| D2.3 | Envelope direction indicator clipped to [-1, 1] | DONE | Transform |
| D2.4 | Regime classification (trend vs range) at configurable threshold | DONE | Transform |
| D2.5 | NaN-drop with audit count in `TransformProductMeta.nan_rows_dropped` | DONE | Transform |
| D2.6 | Transform correlation audit -- max pairwise correlation logged | DONE | Transform |
| D2.7 | Transform validation in Project -- ensure transform columns exist before model inference | DONE | Project |
| D2.8 | All feature columns prefixed `feature_` -- enforced by regex constraint | DONE | Transform |

### D3. Environment Design

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D3.1 | Gymnasium-compatible env via `gym-trading-env` | DONE | Solve/Eval/Project |
| D3.2 | Continuous position ratio action space: [-1, 0, 1] (short, flat, long) | DONE | ExecutionDependent |
| D3.3 | Default `gym-trading-env` log-return reward -- untouched, no custom reward | DONE | Solve |
| D3.4 | Configurable transaction fees (`fees_pct`) and borrow rate (`borrow_rate_pct`) | DONE | ExecutionDependent |
| D3.5 | Solve/eval/project env parity via shared `ExecutionDependent` + `ConstraintDependent` | DONE | Dependent |
| D3.6 | `VecNormalize` for input/signal -- the only enhancement layer | DONE | Solve |
| D3.7 | `SubprocVecEnv` when `n_parallel > 1` in sim mode, `DummyVecEnv` otherwise | DONE | Solve |

### D4. Solve Pipeline

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D4.1 | Solver dispatch -- PPO, SAC, DQN, A2C via `SolverInductive` enum | DONE | Solve |
| D4.2 | `MlpPolicy` hardcoded (correct for flat input) | DONE | Solve |
| D4.3 | Model + VecNormalize blobs saved to `StoreMonad` | DONE | Solve |
| D4.4 | SB3 CSV logger under `store/blobs/{session_id}/logs/` | DONE | Solve |
| D4.5 | Seed propagation for reproducibility | DONE | Solve |
| D4.6 | GPU detection and usage reporting in `SolveProductMeta.gpu_used` | DONE | Solve |
| D4.7 | Episode statistics (mean/std reward, episode count) in `SolveProductMeta` | DONE | Solve |

### D5. Evaluation

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D5.1 | Out-of-sample eval with deterministic prediction | DONE | Eval |
| D5.2 | Per-step stop-loss gate from `ConstraintDependent.stop_loss_pct` | DONE | Eval |
| D5.3 | Per-step take-profit gate from `ConstraintDependent.profit_threshold_pct` | DONE | Eval |
| D5.4 | Position flattening at episode end | DONE | Eval |
| D5.5 | Max drawdown tracking in `EvalProductMeta.max_drawdown_pct` | DONE | Eval |
| D5.6 | Render logs saved for `just ana-eval --eval.launch_renderer true` dashboard | DONE | Eval |
| D5.7 | Walk-forward batch eval with rolling windows via `IOComposePhase` | DONE | Compose |
| D5.8 | Win rate computation across windows (`win_rate_pct`) | DONE | Compose |
| D5.9 | Eval results persisted to `StoreMonad` via `store.put()` | DONE | Eval |

### D6. Live Projection

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D6.1 | Model loaded from `StoreMonad` by `solve_session_id` lookup | DONE | Project |
| D6.2 | Live bar polling at configurable interval (`sample_interval_s`) | DONE | Project |
| D6.3 | Per-step stop-loss and take-profit checks | DONE | Project |
| D6.4 | Model staleness gate (`max_artifact_age_min`) | DONE | Project |
| D6.5 | Data freshness gate (reject data older than 7 days) | DONE | Project |
| D6.6 | Transform column validation before inference | DONE | Project |
| D6.7 | Graceful SIGINT/SIGTERM shutdown with position flattening | DONE | Project |
| D6.8 | Audit JSONL logging to `store/blobs/{session_id}/audit/` | DONE | Project |
| D6.9 | Execution integration -- Alpaca paper/live via `alpaca-py` | DONE | Project |
| D6.10 | Sim/paper/live parity -- same gym env, `execution_mode` toggles execution layer | DONE | Project |
| D6.11 | Market hours check using index-aware local time (not UTC) | DONE | Project |
| D6.12 | Short position handling in execution (`target_pos < 0`) | DONE | Project |
| D6.13 | Execution fill verification -- confirm fill status before incrementing `orders_filled` | DONE | Project |

### D7. Search

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D7.1 | Optuna hyperparameter search via `just hylo-compose --compose.search true` | DONE | Compose |
| D7.2 | Bounded search spaces (learning rate log-scale, budget linear) | DONE | SearchDependent |
| D7.3 | Cross-field validation (`lr_min < lr_max`, `budget_min < budget_max`) | DONE | SearchDependent |
| D7.4 | Journal-based storage for parallel trial safety | DONE | Compose |
| D7.5 | Configurable objective measure (win_rate_pct or avg_return_pct) | DONE | SearchDependent |

### D8. Production Safeguards

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D8.1 | Per-step stop-loss in eval and project | DONE | Eval/Project |
| D8.2 | Per-step take-profit in eval and project | DONE | Eval/Project |
| D8.3 | Position limits via gym-trading-env position ratio [-1, 1] | DONE | ExecutionDependent |
| D8.4 | Model staleness rejection | DONE | Project |
| D8.5 | Data freshness rejection | DONE | Project |
| D8.6 | Full Pydantic validation -- all fields bounded, no `Optional`/`None` | DONE | All Types |
| D8.7 | Structured error handling via `ErrorMonad` (phase, severity, message) | DONE | All IO |
| D8.8 | Graceful shutdown with position flattening | DONE | Project |
| D8.9 | Audit trail (JSONL execution log) | DONE | Project |
| D8.10 | Max drawdown circuit breaker -- halt projection when drawdown exceeds threshold | DONE | Project |

### D9. Observability

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D9.1 | `EffectMonad` composed into every `ProductMeta` (errors, measures, signals, timing) | DONE | All |
| D9.2 | `MeasureMonad` collection per phase (counters + gauges) | DONE | All |
| D9.3 | `SignalMonad` threshold evaluation with severity levels | DONE | Discovery |
| D9.4 | `StoreMonad` -- SQLite artifact DB + filesystem blobs, typed IO boundary | DONE | All |
| D9.5 | SSE event stream observer (absorbed into CoIOComposePhase) | DONE | CoTypes |
| D9.6 | Rerun multi-modal dashboard (absorbed into CoIOComposePhase) | DONE | CoTypes |
| D9.7 | `just ana-eval --eval.launch_renderer true` -- gym-trading-env Flask dashboard | DONE | justfile |

### D10. Type System Integrity

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D10.1 | Every phase has exactly: Hom + ProductOutput + ProductMeta + IO executor + justfile entry | DONE | All |
| D10.2 | Every observer has exactly: CoHom + CoProductOutput + CoProductMeta + IO executor + justfile entry | DONE | CoTypes |
| D10.3 | <=7 fields per type | DONE | All Settings <=7 via local Hom instantiation |
| D10.4 | Every field has `Field(description=...)` | DONE | All |
| D10.5 | Every field bounded (`ge`/`le`/`min_length`/`max_length`) | DONE | All |
| D10.6 | No `Optional`/`None` -- sentinels (`-1.0`, `""`) used instead | DONE | All |
| D10.7 | One type per `default.py` | DONE | All |
| D10.8 | Fully qualified imports | DONE | All |
| D10.9 | External data validated via Inductive types | DONE | Discovery/Ingest |
| D10.10 | `default.json` committed and faithful to type schema | DONE | All 16 JSON files verified |
| D10.11 | CoTypes import paths match filesystem layout | DONE | All 7 CoTypes categories present |
| D10.12 | CoTypes directory naming consistent (`Comonad/`, `CoIO/`) | DONE | Verified on filesystem |
| D10.13 | All filenames must be `default.*` or `__init__.py` -- no exceptions | DONE | All |
| D10.14 | All directory names start with uppercase letter | DONE | All |
| D10.15 | `just ana-check` passes with zero failures | DONE | Validate |

---

## Known Bugs

Tracked issues that must be fixed before the system is considered done.

| ID | Severity | Description | Status |
|----|----------|-------------|--------|
| B1 | BLOCKER | CoHom imports broken -- files misplaced | **CLOSED** |
| B2 | BLOCKER | `CoMonad/` vs `Comonad/` casing; `CoTypes/IO/` vs `CoTypes/CoIO/` | **CLOSED** |
| B3 | BUG | `_is_market_open()` compares UTC to US Eastern trade hours | **CLOSED** |
| B4 | BUG | Eval results not persisted to StoreMonad (`store.put()` missing) | **CLOSED** |
| B5 | BUG | Execution `orders_filled` incremented without fill verification | **CLOSED** |
| B6 | BUG | Short positions (`target_pos < 0`) silently ignored by execution | **CLOSED** |
| B7 | BUG | Top-level `import torch` in IOComposePhase | **CLOSED** |
| B8 | BUG | IOEvalPhase/IOComposePhase Settings >7 fields | **CLOSED** |
| B9 | COSMETIC | Discovery `default.json` missing `signals` key | **CLOSED** |
| B10 | COSMETIC | Stale `execution_mode` in Project `default.json` | **CLOSED** |
| B11 | GAP | `FilterDependent` fields declared but unused | **CLOSED** |
| B12 | GAP | `SolveProductMeta.early_stopped` never set | **CLOSED** |
| B13 | GAP | Data gaps detected but not handled | **CLOSED** |
| B14 | COSMETIC | `CoTypes/CoIO/IOTailPhase/` uses `IO` prefix, not `CoIO` | **CLOSED** (dissolved) |
| B15 | COSMETIC | `CoTypes/CoIO/IOVisualizePhase/` uses `IO` prefix, not `CoIO` | **CLOSED** (dissolved) |
| B16 | COSMETIC | Stale `Types/IO/Validate/default.py` superseded by CoIO version | **CLOSED** |
| B17 | GAP | `CoTypes/CoProduct/{Eval,Transform,Project,Solve}/` stubs (no Output/Meta) | **CLOSED** |

---

## Frozen Phase Chain (7 Phases)

```
Discovery -> Ingest -> Transform -> Solve -> Eval -> Project -> Compose
```

7 phases mapping to 7 states of matter (coldest to hottest):

| # | Matter | Phase | IO Executor | Type Theory | Intuition |
|---|--------|-------|-------------|-------------|-----------|
| 1 | BEC | Discovery | IODiscoveryPhase | Unit (top) | "What universe exists?" |
| 2 | Crystalline | Ingest | IOIngestPhase | Inductive (ADT) | "What data structure?" |
| 3 | Liquid Crystal | Transform | IOTransformPhase | Dependent type | "What geometry?" |
| 4 | Liquid | Solve | IOSolvePhase | Function (A -> B) | "What transformation?" |
| 5 | Gas | Eval | IOEvalPhase | Product/Sum | "What outcomes?" |
| 6 | Plasma | Project | IOProjectPhase | Monad (M A) | "What effects?" |
| 7 | QGP | Compose | IOComposePhase | IO | "Deploy everything" |

## 1:1 Phase Mapping

Every phase has exactly: Hom + ProductOutput + ProductMeta + IO executor + justfile entry.

| Phase | Hom (input) | ProductOutput | IO Executor | justfile |
|-------|-------------|---------------|-------------|----------|
| Discovery | DiscoveryHom | DiscoveryProductOutput | IODiscoveryPhase | `cata-discover` |
| Ingest | IngestHom | IngestProductOutput | IOIngestPhase | `cata-ingest` |
| Transform | TransformHom | TransformProductOutput | IOTransformPhase | `cata-transform` |
| Solve | SolveHom | SolveProductOutput | IOSolvePhase | `cata-solve` |
| Eval | EvalHom | EvalProductOutput | IOEvalPhase | `cata-eval` |
| Project | ProjectHom | ProjectProductOutput | IOProjectPhase | `cata-project` |
| Compose | ComposeHom | ComposeProductOutput | IOComposePhase | `hylo-compose` |

## Architecture

```
RL-Lab/
├── pyproject.toml
├── justfile                       # [QGP] Single IO boundary -- all phase invocations
├── README.md                      # System design + implementation plan + done criteria
├── AGENTS.md                      # Design invariants for agents
├── DICTIONARY.md                  # Domain terms -> type-theoretic placements
├── TRACKER.md                     # Change log and progress tracking
├── Types/
│   ├── Identity/                  # [BEC] Terminal objects -- Index, Session
│   ├── Inductive/                 # [Crystalline] Sum types / ADTs -- Frame, Catalog, CatalogEntry, IndexMeta, Solver, Severity, Measure
│   ├── Dependent/                 # [Liquid Crystal] Parameterized fibers -- Execution, Constraint, Filter, Threshold, Search
│   ├── Hom/                       # [Liquid] Phase inputs / morphisms
│   │   ├── Discovery/
│   │   ├── Ingest/
│   │   ├── Transform/
│   │   ├── Solve/
│   │   ├── Eval/
│   │   ├── Project/
│   │   └── Compose/
│   ├── Product/                   # [Gas] Phase outputs + meta
│   │   ├── {Phase}/Output/
│   │   └── {Phase}/Meta/
│   ├── Monad/                     # [Plasma] Effect record types -- Error, Measure, Signal, Effect, Store, Artifact
│   └── IO/                        # [QGP] IO executors -- BaseSettings + run() + __main__
│       ├── IODiscoveryPhase/
│       ├── IOIngestPhase/
│       ├── IOTransformPhase/
│       ├── IOSolvePhase/
│       ├── IOEvalPhase/
│       ├── IOProjectPhase/
│       └── IOComposePhase/
├── CoTypes/
│   ├── CoIdentity/                # [BEC dual] Introspection witnesses -- Index, Session
│   ├── CoInductive/               # [Crystalline dual] Elimination forms -- Frame, Catalog, Solver, IndexMeta, CatalogEntry
│   ├── CoDependent/               # [Liquid Crystal dual] Schema conformance -- Execution, Constraint, Filter, Threshold, Search
│   ├── CoHom/                     # [Liquid dual] Observation specs -- per-phase (7)
│   ├── CoProduct/                 # [Gas dual] Observation results -- per-phase (7)
│   ├── Comonad/                   # [Plasma dual] Observation witnesses -- Trace, Error, Measure, Signal, Store
│   └── CoIO/                      # [QGP dual] Observer executors
│       ├── CoIODiscoveryPhase/
│       ├── CoIOIngestPhase/
│       ├── CoIOTransformPhase/
│       ├── CoIOSolvePhase/
│       ├── CoIOEvalPhase/
│       ├── CoIOProjectPhase/
│       └── CoIOComposePhase/      # Composite: artifact probe + type validation + optional Rerun visualization
└── store/
    ├── .rl.db                     # SQLite artifact DB (auto-created)
    ├── blobs/                     # Binary artifacts -- models, pickles, audit logs
    │   └── {session_id}/
    │       ├── {phase}_{type}.pkl / .zip / .json
    │       ├── audit/             # Execution audit logs (JSONL)
    │       └── render_logs/       # gym-trading-env history for Flask dashboard
    └── docs/                      # Tracker markdown files
```

## Phase Detail

### Phase 1 -- Discovery (BEC)

**Goal:** Find the single best-trending tradeable index from a universe.

**Pipeline:** Catalog fetch -> Index class routing -> Filter application -> Trend scoring -> Sort descending -> Pick top index.

**Inputs:** `DiscoveryHom` (io_indices, catalog_source, min_trend_score, min_frame_length, trend_lookback, filter, thresholds)
**Outputs:** `DiscoveryProductOutput` (qualifying indices sorted by trend score desc, universe_size, min_trend_score_used)
**Meta:** catalog_result_count, trend_filtered_count, filter_count, index_class_filtered_count, top_trend_score

**External IO:** yfinance catalog API, yfinance Ticker.info, yfinance download (for trend calc).
**Validation:** `CatalogInductive.from_io_response()`, `IndexMetaInductive.from_info()`, `FrameInductive.from_io_frame()`.

### Phase 2 -- Ingest (Crystalline)

**Goal:** Download and cache clean frame data for a single index.

**Pipeline:** Check cache -> Download via yfinance -> Validate via FrameInductive -> Trim warmup frames -> Detect gaps -> Pickle to blob -> Record in StoreMonad.

**Inputs:** `IngestHom` (period, warmup_frames) + `IndexIdentity` (io_ticker, interval_min)
**Outputs:** `IngestProductOutput` (io_ticker, interval_min, n_bars)
**Meta:** cache_hit, raw_bar_count, warmup_trimmed, data_gaps_count, api_calls

### Phase 3 -- Transform (Liquid Crystal)

**Goal:** Transform raw frame data into smooth, information-dense geometry.

**Pipeline:** Load ingest blob from store -> Basis denoise 5 channels (3 features each: denoised_pct, approx_pct, detail_energy) -> Trend normalized -> Envelope direction -> Regime flag -> Drop NaN -> Pickle to blob.

**Inputs:** `TransformHom` (basis, level, threshold_mode, trend_period, envelope_period, envelope_multiplier, regime_threshold)
**Outputs:** `TransformProductOutput` (n_static_features, n_dynamic_features, n_valid_bars, feature_names)
**Meta:** basis_level_used, nan_rows_dropped, regime_trending_pct, feature_correlation_max

**Feature columns (18 static):**
- 5x `feature_{ch}_denoised_pct` -- basis-denoised percent change
- 5x `feature_{ch}_approx_pct` -- approximation coefficient percent change
- 5x `feature_{ch}_detail_energy` -- detail coefficient energy [0, 1]
- 1x `feature_trend` -- trend indicator normalized to [0, 1]
- 1x `feature_envelope_dir` -- envelope direction [-1, 1]
- 1x `feature_regime` -- binary trend/range flag {0, 1}

**Dynamic features (2):** position state from gym-trading-env.

### Phase 4 -- Solve (Liquid)

**Goal:** Learn a policy mapping inputs to position actions.

**Pipeline:** Load transform blob -> Create gym env(s) -> Wrap in VecNormalize -> Initialize SB3 model -> Solve for budget steps -> Save model.zip + normalize.pkl to store.

**Inputs:** `SolveHom` (solver, n_parallel, learning_rate, budget, horizon_min, normalize_input, normalize_signal)
**Outputs:** `SolveProductOutput` (solver, budget, final_reward)
**Meta:** episodes_completed, mean_episode_reward, std_episode_reward, early_stopped, gpu_used

### Phase 5 -- Eval (Gas)

**Goal:** Measure out-of-sample performance with constraint gates.

**Pipeline:** Load model + normalize from store -> Create eval env with render_mode="logs" -> Run deterministic episode -> Check stop-loss/take-profit per step -> Flatten position at end -> Save render logs.

**Inputs:** `EvalHom` (horizon_min) + `ConstraintDependent` (stop_loss_pct, profit_threshold_pct)
**Outputs:** `EvalProductOutput` (io_ticker, window_index, portfolio_return_pct, final_value, threshold_met)
**Meta:** steps_taken, stop_loss_triggered, take_profit_triggered, max_drawdown_pct, position_changes

### Phase 6 -- Project (Plasma)

**Goal:** Execute a solved model bar-by-bar against live (or paper) market data.

**Pipeline:** Load model from store -> Validate artifact age -> Poll live bar -> Validate data freshness -> Validate transforms -> Model predict -> Constraint check -> Execute order (if paper/live) -> Audit log -> Repeat until max_frames or shutdown.

**Inputs:** `ProjectHom` (solve_session_id, io_solver, sample_interval_s, max_frames, max_artifact_age_min)
**Outputs:** `ProjectProductOutput` (io_ticker, n_bars_served, portfolio_return_pct, position_taken, status)
**Meta:** execution_calls, execution_failures, orders_submitted, orders_filled, shutdown_reason

**Safeguards:** stop-loss, take-profit, artifact staleness, data freshness, transform validation, graceful shutdown, audit JSONL.

### Phase 7 -- Compose (QGP)

**Goal:** Orchestrate the full pipeline with walk-forward evaluation and optional HPO.

**Pipeline:**
1. Discovery -> pick top index
2. Ingest -> cache frame data
3. Transform -> engineer features
4. Slide window: for each stride, split solve/eval, run Solve -> Eval
5. Collect results, compute win_rate_pct
6. (Optional) Optuna wraps steps 4-5 as objective function

**Inputs:** `ComposeHom` (stride_min, solve_split_pct, search, search_fiber)
**Outputs:** `ComposeProductOutput` (n_windows, win_rate_pct, duration_s, status, results)
**Meta:** search trial results (if search=True)

## Matter-Phase Type System

| # | Phase | Type Theory | Matter | Directory | Naming | Types |
|---|-------|-------------|--------|-----------|--------|-------|
| 1 | Identity | Unit (top) | BEC | `Types/Identity/` | `{Domain}Identity` | IndexIdentity, SessionIdentity |
| 2 | Inductive | ADT | Crystalline | `Types/Inductive/` | `{Domain}Inductive` | FrameInductive, CatalogInductive, CatalogEntryInductive, IndexMetaInductive, SolverInductive, SeverityInductive, MeasureInductive |
| 3 | Dependent | Indexed | Liquid Crystal | `Types/Dependent/` | `{Domain}Dependent` | ExecutionDependent, ConstraintDependent, FilterDependent, ThresholdDependent, SearchDependent |
| 4 | Hom | Function | Liquid | `Types/Hom/` | `{Domain}Hom` | DiscoveryHom, IngestHom, TransformHom, SolveHom, EvalHom, ProjectHom, ComposeHom |
| 5 | Product | Sum/Product | Gas | `Types/Product/` | `{Domain}Product{Kind}` | {Phase}ProductOutput + {Phase}ProductMeta (x7 each) |
| 6 | Monad | Effect | Plasma | `Types/Monad/` | `{Domain}Monad` | ErrorMonad, MeasureMonad, SignalMonad, EffectMonad, StoreMonad, ArtifactMonad |
| 7 | IO | IO | QGP | `Types/IO/` | `IO{Phase}Phase` | IODiscoveryPhase ... IOComposePhase (x7) |

## Product Types (Phase Outputs)

| Phase | Output | Meta | Output Fields |
|-------|--------|------|---------------|
| Discovery | DiscoveryProductOutput | DiscoveryProductMeta | session_id, universe_size, qualifying_indices, min_trend_score_used, meta |
| Ingest | IngestProductOutput | IngestProductMeta | session_id, io_ticker, interval_min, n_bars, meta |
| Transform | TransformProductOutput | TransformProductMeta | session_id, n_static_features, n_dynamic_features, n_valid_bars, feature_names, meta |
| Solve | SolveProductOutput | SolveProductMeta | session_id, solver, budget, final_reward, meta |
| Eval | EvalProductOutput | EvalProductMeta | session_id, io_ticker, window_index, portfolio_return_pct, final_value, threshold_met, meta |
| Project | ProjectProductOutput | ProjectProductMeta | session_id, io_ticker, n_bars_served, portfolio_return_pct, position_taken, status, meta |
| Compose | ComposeProductOutput | ComposeProductMeta | session_id, n_windows, win_rate_pct, duration_s, status, results, meta |

## CoTypes -- Coalgebraic Observers

Observers are covariant presheaves -- they observe the system without participating in the phase chain. Each of the 7 production phases has a corresponding `ana-{phase}` observer in `CoTypes/CoIO/`. Tail (SSE stream) and Visualize (Rerun dashboard) functionality is absorbed into `CoIOComposePhase` as the composite observer.

Comonad observation witnesses (5 types in `CoTypes/Comonad/`): TraceComonad, CoErrorComonad, CoMeasureComonad, CoSignalComonad, CoStoreComonad.

## Execution Integration

| Mode | Gym Env | Execution Calls | Endpoint |
|------|---------|----------------|----------|
| **sim** (default) | Backtest only | None | N/A |
| **paper** | Same gym env | Alpaca paper orders | paper-api.alpaca.markets |
| **live** | Same gym env | Alpaca live orders | api.alpaca.markets |

- Gym env stays pure across all modes -- execution is a thin post-loop hook
- API keys in `.env` at project root (gitignored), loaded via `load_dotenv()`
- Setup: `ALPACA_API_KEY` and `ALPACA_SECRET_KEY` in `.env`
- Activate: `just cata-project --execution.execution_mode paper`

## Dependencies

```
gymnasium, gym-trading-env, stable-baselines3[extra], yfinance,
PyWavelets, pandas-ta, matplotlib, pandas, numpy,
pydantic, pydantic-settings, optuna, alpaca-py,
sqlalchemy, rerun-sdk, sseclient-py, returns
```

## Search

```bash
just hylo-compose --compose.search true --compose.search_fiber.budget 20
```

Optuna searches over learning rate (log-scale) and budget (linear) within bounded ranges defined by `SearchDependent`. Uses journal-based storage for safe parallel trials.

## Competitive Positioning

Compared against FinRL (14k stars), TensorTrade (6k stars), gym-trading-env, and SB3:

**What this project does that others do not:**
- Index auto-discovery with regime detection (no static ticker lists)
- Model staleness and data freshness gates (no other framework implements these)
- Graceful shutdown with position flattening
- Audit trail (JSONL execution log)
- Full typed pipeline orchestration with artifact store (StoreMonad)
- Basis denoising on all frame channels
- Coalgebraic observer layer (per-phase ana- observers + composite CoIOComposePhase)
- Monadic IO via `dry-python/returns` (typed effect handling, no bare exceptions)

**What this project does not do (by design):**
- Multi-index simultaneous portfolio (single-index focus; IndexIdentity supports rotation)
- Ensemble methods (single model per session)
- Custom reward functions (gym-trading-env default is the invariant)
- Slippage modeling (not yet implemented; potential future ConstraintDependent field)
