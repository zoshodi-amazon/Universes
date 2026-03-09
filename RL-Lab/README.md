# RL Trading Sandbox

Autonomous self-hosted quant RL lab. Asset-agnostic (stocks, crypto, forex).

## Synopsis

```
# cata- (Catamorphism) — production, Types/ -> Artifact
just cata-discover       # Phase 1 (BEC): Find trending assets
just cata-ingest         # Phase 2 (Crystalline): Download OHLCV data
just cata-feature        # Phase 3 (Liquid Crystal): Wavelet + indicators
just cata-train          # Phase 4 (Liquid): RL model training
just cata-eval           # Phase 5 (Gas): Out-of-sample evaluation
just cata-serve          # Phase 6 (Plasma): Live serving with broker

# ana- (Anamorphism) — observation, Artifact -> CoTypes/
just ana-validate         # Validate type schemas + JSON roundtrip
just ana-discover        # Observe last DiscoveryProductOutput from store
just ana-ingest          # Observe last IngestProductOutput
just ana-feature         # Observe FeatureProductOutput geometry stats
just ana-train           # Observe TrainProductOutput learning curves
just ana-eval            # Observe EvalProductOutput return/drawdown
just ana-serve           # Observe ServeProductOutput broker/audit
just ana-main            # Observe MainProductOutput pipeline summary
just ana-render <run_id> # Render dashboard for a specific run
just ana-main            # Observe MainProductOutput pipeline summary

# hylo- (Hylomorphism) — composite, ana then cata
just hylo-main           # Phase 7 (QGP): Full pipeline
```

## Definition of Done

The system is complete when every item below is implemented, tested, and documented.
Each item maps to a checklist entry. No item may be removed. Items may only be added.

### D1. Data Pipeline

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D1.1 | Multi-source OHLCV ingestion (yfinance + Alpaca) | DONE | Ingest |
| D1.2 | OHLCV schema validation via `OHLCVInductive.from_dataframe()` — no raw dicts cross IO boundary | DONE | Ingest |
| D1.3 | Pickle caching under `store/blobs/cache/` with cache-hit tracking | DONE | Ingest |
| D1.4 | Data freshness gate — reject data older than 7 days in Serve | DONE | Serve |
| D1.5 | Temporal gap detection — `data_gaps_count` recorded in `IngestProductMeta` | DONE | Ingest |
| D1.6 | Temporal gap handling — forward-fill or warn when gaps exceed 2x expected interval | DONE | Ingest |
| D1.7 | Walk-forward temporal splits — no lookahead leakage via `IOMainPhase` windowing | DONE | Main |
| D1.8 | Asset-agnostic support — stocks, crypto, forex via `AssetIdentity` routing | DONE | Discovery |

### D2. Feature Engineering

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D2.1 | Wavelet (db4) denoising on all 5 OHLCV channels — denoised_pct, approx_pct, detail_energy | DONE | Feature |
| D2.2 | ADX trend indicator normalized to [0, 1] | DONE | Feature |
| D2.3 | SuperTrend direction indicator clipped to [-1, 1] | DONE | Feature |
| D2.4 | ADX regime classification (trend vs range) at configurable threshold | DONE | Feature |
| D2.5 | NaN-drop with audit count in `FeatureProductMeta.nan_rows_dropped` | DONE | Feature |
| D2.6 | Feature correlation audit — max pairwise correlation logged | DONE | Feature |
| D2.7 | Feature validation in Serve — ensure feature columns exist before model inference | DONE | Serve |
| D2.8 | All feature columns prefixed `feature_` — enforced by regex constraint | DONE | Feature |

### D3. Environment Design

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D3.1 | Gymnasium-compatible env via `gym-trading-env` | DONE | Train/Eval/Serve |
| D3.2 | Continuous position ratio action space: [-1, 0, 1] (short, flat, long) | DONE | EnvDependent |
| D3.3 | Default `gym-trading-env` log-return reward — untouched, no custom reward | DONE | Train |
| D3.4 | Configurable transaction fees (`fees_pct`) and borrow rate (`borrow_rate_pct`) | DONE | EnvDependent |
| D3.5 | Train/eval/serve env parity via shared `EnvDependent` + `RiskDependent` | DONE | Dependent |
| D3.6 | `VecNormalize` for obs/reward — the only enhancement layer | DONE | Train |
| D3.7 | `SubprocVecEnv` when `n_envs > 1` in sim mode, `DummyVecEnv` otherwise | DONE | Train |

### D4. Training Pipeline

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D4.1 | Algorithm dispatch — PPO, SAC, DQN, A2C via `AlgoIdentity` enum | DONE | Train |
| D4.2 | `MlpPolicy` hardcoded (correct for flat obs) | DONE | Train |
| D4.3 | Model + VecNormalize blobs saved to `StoreMonad` | DONE | Train |
| D4.4 | SB3 CSV logger under `store/blobs/{run_id}/logs/` | DONE | Train |
| D4.5 | Seed propagation for reproducibility | DONE | Train |
| D4.6 | GPU detection and usage reporting in `TrainProductMeta.gpu_used` | DONE | Train |
| D4.7 | Episode statistics (mean/std reward, episode count) in `TrainProductMeta` | DONE | Train |

### D5. Evaluation

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D5.1 | Out-of-sample eval with deterministic prediction | DONE | Eval |
| D5.2 | Per-step stop-loss gate from `RiskDependent.stop_loss_pct` | DONE | Eval |
| D5.3 | Per-step take-profit gate from `RiskDependent.profit_threshold_pct` | DONE | Eval |
| D5.4 | Position flattening at episode end | DONE | Eval |
| D5.5 | Max drawdown tracking in `EvalProductMeta.max_drawdown_pct` | DONE | Eval |
| D5.6 | Render logs saved for `just ana-render <run_id>` dashboard | DONE | Eval |
| D5.7 | Walk-forward batch eval with rolling windows via `IOMainPhase` | DONE | Main |
| D5.8 | Win rate computation across windows (`win_rate_pct`) | DONE | Main |
| D5.9 | Eval results persisted to `StoreMonad` via `store.put()` | DONE | Eval |

### D6. Live Serving

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D6.1 | Model loaded from `StoreMonad` by `train_run_id` lookup | DONE | Serve |
| D6.2 | Live bar polling at configurable interval (`poll_interval_s`) | DONE | Serve |
| D6.3 | Per-step stop-loss and take-profit checks | DONE | Serve |
| D6.4 | Model staleness gate (`max_model_age_min`) | DONE | Serve |
| D6.5 | Data freshness gate (reject data older than 7 days) | DONE | Serve |
| D6.6 | Feature column validation before inference | DONE | Serve |
| D6.7 | Graceful SIGINT/SIGTERM shutdown with position flattening | DONE | Serve |
| D6.8 | Audit JSONL logging to `store/blobs/{run_id}/audit/` | DONE | Serve |
| D6.9 | Broker integration — Alpaca paper/live via `alpaca-py` | DONE | Serve |
| D6.10 | Sim/paper/live parity — same gym env, `broker_mode` toggles execution layer | DONE | Serve |
| D6.11 | Market hours check using asset-aware local time (not UTC) | DONE | Serve |
| D6.12 | Short position handling in broker execution (`target_pos < 0`) | DONE | Serve |
| D6.13 | Broker fill verification — confirm fill status before incrementing `orders_filled` | DONE | Serve |

### D7. Optimization

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D7.1 | Optuna hyperparameter search via `just hylo-main --main.optimize true` | DONE | Main |
| D7.2 | Bounded search spaces (learning rate log-scale, timesteps linear) | DONE | OptimizeDependent |
| D7.3 | Cross-field validation (`lr_min < lr_max`, `timesteps_min < timesteps_max`) | DONE | OptimizeDependent |
| D7.4 | Journal-based storage for parallel trial safety | DONE | Main |
| D7.5 | Configurable objective metric (win_rate_pct or avg_return_pct) | DONE | OptimizeDependent |

### D8. Production Safeguards

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D8.1 | Per-step stop-loss in eval and serve | DONE | Eval/Serve |
| D8.2 | Per-step take-profit in eval and serve | DONE | Eval/Serve |
| D8.3 | Position limits via gym-trading-env position ratio [-1, 1] | DONE | EnvDependent |
| D8.4 | Model staleness rejection | DONE | Serve |
| D8.5 | Data freshness rejection | DONE | Serve |
| D8.6 | Full Pydantic validation — all fields bounded, no `Optional`/`None` | DONE | All Types |
| D8.7 | Structured error handling via `ErrorMonad` (phase, severity, message) | DONE | All IO |
| D8.8 | Graceful shutdown with position flattening | DONE | Serve |
| D8.9 | Audit trail (JSONL trade log) | DONE | Serve |
| D8.10 | Max drawdown circuit breaker — halt serving when drawdown exceeds threshold | DONE | Serve |

### D9. Observability

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D9.1 | `ObservabilityMonad` composed into every `ProductMeta` (errors, metrics, alarms, timing) | DONE | All |
| D9.2 | `MetricMonad` collection per phase (counters + gauges) | DONE | All |
| D9.3 | `AlarmMonad` threshold evaluation with severity levels | DONE | Discovery |
| D9.4 | `StoreMonad` — SQLite artifact DB + filesystem blobs, typed IO boundary | DONE | All |
| D9.5 | SSE event stream observer (absorbed into CoIOMainPhase) | DONE | CoTypes |
| D9.6 | Rerun multi-modal dashboard (absorbed into CoIOMainPhase) | DONE | CoTypes |
| D9.7 | `just ana-render <run_id>` — gym-trading-env Flask dashboard | DONE | justfile |

### D10. Type System Integrity

| # | Requirement | Status | Phase |
|---|-------------|--------|-------|
| D10.1 | Every phase has exactly: Hom + ProductOutput + ProductMeta + IO executor + justfile entry | DONE | All |
| D10.2 | Every observer has exactly: CoHom + CoProductOutput + CoProductMeta + IO executor + justfile entry | DONE | CoTypes |
| D10.3 | ≤7 fields per type | DONE | All Settings <=7 via local Hom instantiation |
| D10.4 | Every field has `Field(description=...)` | DONE | All |
| D10.5 | Every field bounded (`ge`/`le`/`min_length`/`max_length`) | DONE | All |
| D10.6 | No `Optional`/`None` — sentinels (`-1.0`, `""`) used instead | DONE | All |
| D10.7 | One type per `default.py` | DONE | All |
| D10.8 | Fully qualified imports | DONE | All |
| D10.9 | External data validated via Inductive types | DONE | Discovery/Ingest |
| D10.10 | `default.json` committed and faithful to type schema | DONE | All 16 JSON files verified |
| D10.11 | CoTypes import paths match filesystem layout | DONE | All 7 CoTypes categories present |
| D10.12 | CoTypes directory naming consistent (`Comonad/`, `CoIO/`) | DONE | Verified on filesystem |
| D10.13 | All filenames must be `default.*` or `__init__.py` — no exceptions | DONE | All |
| D10.14 | All directory names start with uppercase letter | DONE | All |
| D10.15 | `just ana-validate` passes with zero failures | DONE | Validate |

---

## Known Bugs

Tracked issues that must be fixed before the system is considered done.

| ID | Severity | Description | Status |
|----|----------|-------------|--------|
| B1 | BLOCKER | CoHom imports broken — files misplaced | **CLOSED** |
| B2 | BLOCKER | `CoMonad/` vs `Comonad/` casing; `CoTypes/IO/` vs `CoTypes/CoIO/` | **CLOSED** |
| B3 | BUG | `_is_market_open()` compares UTC to US Eastern trade hours | **CLOSED** |
| B4 | BUG | Eval results not persisted to StoreMonad (`store.put()` missing) | **CLOSED** |
| B5 | BUG | Broker `orders_filled` incremented without fill verification | **CLOSED** |
| B6 | BUG | Short positions (`target_pos < 0`) silently ignored by broker | **CLOSED** |
| B7 | BUG | Top-level `import torch` in IOMainPhase | **CLOSED** |
| B8 | BUG | IOEvalPhase/IOMainPhase Settings >7 fields | **CLOSED** |
| B9 | COSMETIC | Discovery `default.json` missing `alarms` key | **CLOSED** |
| B10 | COSMETIC | Stale `broker_mode` in Serve `default.json` | **CLOSED** |
| B11 | GAP | `LiquidityDependent` fields declared but unused | **CLOSED** |
| B12 | GAP | `TrainProductMeta.early_stopped` never set | **CLOSED** |
| B13 | GAP | Data gaps detected but not handled | **CLOSED** |
| B14 | COSMETIC | `CoTypes/CoIO/IOTailPhase/` uses `IO` prefix, not `CoIO` | **CLOSED** (dissolved) |
| B15 | COSMETIC | `CoTypes/CoIO/IOVisualizePhase/` uses `IO` prefix, not `CoIO` | **CLOSED** (dissolved) |
| B16 | COSMETIC | Stale `Types/IO/Validate/default.py` superseded by CoIO version | **CLOSED** |
| B17 | GAP | `CoTypes/CoProduct/{Eval,Feature,Serve,Train}/` stubs (no Output/Meta) | OPEN |

---

## Frozen Phase Chain (7 Phases)

```
Discovery -> Ingest -> Feature -> Train -> Eval -> Serve -> Main
```

7 phases mapping to 7 states of matter (coldest to hottest):

| # | Matter | Phase | IO Executor | Type Theory | Intuition |
|---|--------|-------|-------------|-------------|-----------|
| 1 | BEC | Discovery | IODiscoveryPhase | Unit (top) | "What universe exists?" |
| 2 | Crystalline | Ingest | IOIngestPhase | Inductive (ADT) | "What data structure?" |
| 3 | Liquid Crystal | Feature | IOFeaturePhase | Dependent type | "What geometry?" |
| 4 | Liquid | Train | IOTrainPhase | Function (A -> B) | "What transformation?" |
| 5 | Gas | Eval | IOEvalPhase | Product/Sum | "What outcomes?" |
| 6 | Plasma | Serve | IOServePhase | Monad (M A) | "What effects?" |
| 7 | QGP | Main | IOMainPhase | IO | "Deploy everything" |

## 1:1 Phase Mapping

Every phase has exactly: Hom + ProductOutput + ProductMeta + IO executor + justfile entry.

| Phase | Hom (input) | ProductOutput | IO Executor | justfile |
|-------|-------------|---------------|-------------|----------|
| Discovery | DiscoveryHom | DiscoveryProductOutput | IODiscoveryPhase | `cata-discover` |
| Ingest | IngestHom | IngestProductOutput | IOIngestPhase | `cata-ingest` |
| Feature | FeatureHom | FeatureProductOutput | IOFeaturePhase | `cata-feature` |
| Train | TrainHom | TrainProductOutput | IOTrainPhase | `cata-train` |
| Eval | EvalHom | EvalProductOutput | IOEvalPhase | `cata-eval` |
| Serve | ServeHom | ServeProductOutput | IOServePhase | `cata-serve` |
| Main | MainHom | MainProductOutput | IOMainPhase | `hylo-main` |

## Architecture

```
RL/
├── pyproject.toml
├── justfile                       # [QGP] Single IO boundary — all phase invocations
├── README.md                      # System design + implementation plan + done criteria
├── AGENTS.md                      # Design invariants for agents
├── DICTIONARY.md                  # Domain terms -> type-theoretic placements
├── TRACKER.md                     # Change log and progress tracking
├── Types/
│   ├── Identity/                  # [BEC] Terminal objects — Asset, Run
│   ├── Inductive/                 # [Crystalline] Sum types / ADTs — OHLCV, Screener, TickerInfo, Algo, AlarmSeverity, MetricKind
│   ├── Dependent/                 # [Liquid Crystal] Parameterized configs — Env, Risk, Liquidity, Alarm, Optimize
│   ├── Hom/                       # [Liquid] Phase inputs / morphisms
│   │   ├── Discovery/
│   │   ├── Ingest/
│   │   ├── Feature/
│   │   ├── Train/
│   │   ├── Eval/
│   │   ├── Serve/
│   │   └── Main/
│   ├── Product/                   # [Gas] Phase outputs + meta
│   │   ├── {Phase}/Output/
│   │   └── {Phase}/Meta/
│   ├── Monad/                     # [Plasma] Effect record types — Error, Metric, Alarm, Observability, Store, Artifact
│   └── IO/                        # [QGP] IO executors — BaseSettings + run() + __main__
│       ├── IODiscoveryPhase/
│       ├── IOIngestPhase/
│       ├── IOFeaturePhase/
│       ├── IOTrainPhase/
│       ├── IOEvalPhase/
│       ├── IOServePhase/
│       └── IOMainPhase/
├── CoTypes/
│   ├── CoIdentity/                # [BEC dual] Introspection witnesses — Asset, Run
│   ├── CoInductive/               # [Crystalline dual] Elimination forms — OHLCV, Screener, Algo, TickerInfo, ScreenerQuote
│   ├── CoDependent/               # [Liquid Crystal dual] Schema conformance — Env, Risk, Liquidity, Alarm, Optimize
│   ├── CoHom/                     # [Liquid dual] Observation specs — per-phase (7)
│   ├── CoProduct/                 # [Gas dual] Observation results — per-phase (7)
│   ├── Comonad/                   # [Plasma dual] Observation witnesses — Trace, Error, Metric, Alarm, Store
│   └── CoIO/                      # [QGP dual] Observer executors
│       ├── CoIODiscoveryPhase/
│       ├── CoIOIngestPhase/
│       ├── CoIOFeaturePhase/
│       ├── CoIOTrainPhase/
│       ├── CoIOEvalPhase/
│       ├── CoIOServePhase/
│       └── CoIOMainPhase/         # Composite: artifact probe + type validation + optional Rerun visualization
└── store/
    ├── .rl.db                     # SQLite artifact DB (auto-created)
    ├── blobs/                     # Binary artifacts — models, pickles, audit logs
    │   └── {run_id}/
    │       ├── {phase}_{type}.pkl / .zip / .json
    │       ├── audit/             # Trade audit logs (JSONL)
    │       └── render_logs/       # gym-trading-env history for Flask dashboard
    └── docs/                      # Tracker markdown files
```

## Phase Detail

### Phase 1 — Discovery (BEC)

**Goal:** Find the single best-trending tradeable asset from a universe.

**Pipeline:** Screener fetch -> Asset class routing -> Liquidity filtering -> ADX scoring -> Sort descending -> Pick top ticker.

**Inputs:** `DiscoveryHom` (universe, screener, min_adx, min_bars, adx_lookback_period, liquidity, alarms)
**Outputs:** `DiscoveryProductOutput` (qualifying_tickers sorted by ADX desc, universe_size, min_adx_used)
**Meta:** screener_result_count, adx_filtered_count, liquidity_filtered_count, asset_class_filtered_count, top_adx_score

**External IO:** yfinance screener API, yfinance Ticker.info, yfinance download (for ADX calc).
**Validation:** `ScreenerInductive.from_response()`, `TickerInfoInductive.from_info()`, `OHLCVInductive.from_dataframe()`.

### Phase 2 — Ingest (Crystalline)

**Goal:** Download and cache clean OHLCV data for a single ticker.

**Pipeline:** Check cache -> Download via yfinance -> Validate via OHLCVInductive -> Trim warmup bars -> Detect gaps -> Pickle to blob -> Record in StoreMonad.

**Inputs:** `IngestHom` (period, warmup_bars) + `AssetIdentity` (io_ticker, interval_min)
**Outputs:** `IngestProductOutput` (io_ticker, interval_min, n_bars)
**Meta:** cache_hit, raw_bar_count, warmup_trimmed, data_gaps_count, api_calls

### Phase 3 — Feature (Liquid Crystal)

**Goal:** Transform raw OHLCV into smooth, information-dense feature geometry.

**Pipeline:** Load ingest blob from store -> Wavelet denoise 5 channels (3 features each: denoised_pct, approx_pct, detail_energy) -> ADX normalized -> SuperTrend direction -> Regime flag -> Drop NaN -> Pickle to blob.

**Inputs:** `FeatureHom` (wavelet, level, threshold_mode, adx_period, supertrend_period, supertrend_multiplier, regime_threshold)
**Outputs:** `FeatureProductOutput` (n_static_features, n_dynamic_features, n_valid_bars, feature_names)
**Meta:** wavelet_level_used, nan_rows_dropped, regime_trending_pct, feature_correlation_max

**Feature columns (18 static):**
- 5x `feature_{ch}_denoised_pct` — wavelet-denoised percent change
- 5x `feature_{ch}_approx_pct` — approximation coefficient percent change
- 5x `feature_{ch}_detail_energy` — detail coefficient energy [0, 1]
- 1x `feature_adx` — ADX normalized to [0, 1]
- 1x `feature_supertrend_dir` — SuperTrend direction [-1, 1]
- 1x `feature_regime` — binary trend/range flag {0, 1}

**Dynamic features (2):** position state from gym-trading-env.

### Phase 4 — Train (Liquid)

**Goal:** Learn a policy mapping observations to position actions.

**Pipeline:** Load feature blob -> Create gym env(s) -> Wrap in VecNormalize -> Initialize SB3 model -> Train for total_timesteps -> Save model.zip + normalize.pkl to store.

**Inputs:** `TrainHom` (algo, n_envs, learning_rate, total_timesteps, episode_duration_min, normalize_obs, normalize_reward)
**Outputs:** `TrainProductOutput` (algo, total_timesteps, final_reward)
**Meta:** episodes_completed, mean_episode_reward, std_episode_reward, early_stopped, gpu_used

### Phase 5 — Eval (Gas)

**Goal:** Measure out-of-sample performance with risk gates.

**Pipeline:** Load model + normalize from store -> Create eval env with render_mode="logs" -> Run deterministic episode -> Check stop-loss/take-profit per step -> Flatten position at end -> Save render logs.

**Inputs:** `EvalHom` (forward_steps_min) + `RiskDependent` (stop_loss_pct, profit_threshold_pct)
**Outputs:** `EvalProductOutput` (io_ticker, window_index, portfolio_return_pct, final_value, threshold_met)
**Meta:** steps_taken, stop_loss_triggered, take_profit_triggered, max_drawdown_pct, position_changes

### Phase 6 — Serve (Plasma)

**Goal:** Execute a trained model bar-by-bar against live (or paper) market data.

**Pipeline:** Load model from store -> Validate model age -> Poll live bar -> Validate data freshness -> Validate features -> Model predict -> Risk check -> Execute broker order (if paper/live) -> Audit log -> Repeat until max_bars or shutdown.

**Inputs:** `ServeHom` (train_run_id, io_algo, poll_interval_s, max_bars, max_model_age_min)
**Outputs:** `ServeProductOutput` (io_ticker, n_bars_served, portfolio_return_pct, position_taken, status)
**Meta:** broker_calls, broker_failures, orders_submitted, orders_filled, shutdown_reason

**Safeguards:** stop-loss, take-profit, model staleness, data freshness, feature validation, graceful shutdown, audit JSONL.

### Phase 7 — Main (QGP)

**Goal:** Orchestrate the full pipeline with walk-forward evaluation and optional HPO.

**Pipeline:**
1. Discovery -> pick top ticker
2. Ingest -> cache OHLCV
3. Feature -> engineer features
4. Slide window: for each stride, split train/eval, run Train -> Eval
5. Collect results, compute win_rate_pct
6. (Optional) Optuna wraps steps 4-5 as objective function

**Inputs:** `MainHom` (stride_min, train_split_pct, optimize, optimize_config)
**Outputs:** `MainProductOutput` (n_windows, win_rate_pct, duration_s, status, results)
**Meta:** optimization trial results (if optimize=True)

## Matter-Phase Type System

| # | Phase | Type Theory | Matter | Directory | Naming | Types |
|---|-------|-------------|--------|-----------|--------|-------|
| 1 | Identity | Unit (top) | BEC | `Types/Identity/` | `{Domain}Identity` | AssetIdentity, RunIdentity |
| 2 | Inductive | ADT | Crystalline | `Types/Inductive/` | `{Domain}Inductive` | OHLCVInductive, ScreenerInductive, ScreenerQuoteInductive, TickerInfoInductive, AlgoIdentity, AlarmSeverity, MetricKind |
| 3 | Dependent | Indexed | Liquid Crystal | `Types/Dependent/` | `{Domain}Dependent` | EnvDependent, RiskDependent, LiquidityDependent, AlarmDependent, OptimizeDependent |
| 4 | Hom | Function | Liquid | `Types/Hom/` | `{Domain}Hom` | DiscoveryHom, IngestHom, FeatureHom, TrainHom, EvalHom, ServeHom, MainHom |
| 5 | Product | Sum/Product | Gas | `Types/Product/` | `{Domain}Product{Kind}` | {Phase}ProductOutput + {Phase}ProductMeta (x7 each) |
| 6 | Monad | Effect | Plasma | `Types/Monad/` | `{Domain}Monad` | ErrorMonad, MetricMonad, AlarmMonad, ObservabilityMonad, StoreMonad, ArtifactRow |
| 7 | IO | IO | QGP | `Types/IO/` | `IO{Phase}Phase` | IODiscoveryPhase ... IOMainPhase (x7) |

## Product Types (Phase Outputs)

| Phase | Output | Meta | Output Fields |
|-------|--------|------|---------------|
| Discovery | DiscoveryProductOutput | DiscoveryProductMeta | run_id, universe_size, qualifying_tickers, min_adx_used, meta |
| Ingest | IngestProductOutput | IngestProductMeta | run_id, io_ticker, interval_min, n_bars, meta |
| Feature | FeatureProductOutput | FeatureProductMeta | run_id, n_static_features, n_dynamic_features, n_valid_bars, feature_names, meta |
| Train | TrainProductOutput | TrainProductMeta | run_id, algo, total_timesteps, final_reward, meta |
| Eval | EvalProductOutput | EvalProductMeta | run_id, io_ticker, window_index, portfolio_return_pct, final_value, threshold_met, meta |
| Serve | ServeProductOutput | ServeProductMeta | run_id, io_ticker, n_bars_served, portfolio_return_pct, position_taken, status, meta |
| Main | MainProductOutput | MainProductMeta | run_id, n_windows, win_rate_pct, duration_s, status, results, meta |

## CoTypes — Coalgebraic Observers

Observers are covariant presheaves — they observe the system without participating in the phase chain. Each of the 7 production phases has a corresponding `ana-{phase}` observer in `CoTypes/CoIO/`. Tail (SSE stream) and Visualize (Rerun dashboard) functionality is absorbed into `CoIOMainPhase` as the composite observer.

Comonad observation witnesses (5 types in `CoTypes/Comonad/`): TraceComonad, CoErrorComonad, CoMetricComonad, CoAlarmComonad, CoStoreComonad.

## Broker Integration

| Mode | Gym Env | Broker Calls | Endpoint |
|------|---------|-------------|----------|
| **sim** (default) | Backtest only | None | N/A |
| **paper** | Same gym env | Alpaca paper orders | paper-api.alpaca.markets |
| **live** | Same gym env | Alpaca live orders | api.alpaca.markets |

- Gym env stays pure across all modes — broker is a thin post-loop hook
- API keys in `.env` at project root (gitignored), loaded via `load_dotenv()`
- Setup: `ALPACA_API_KEY` and `ALPACA_SECRET_KEY` in `.env`
- Activate: `just cata-serve --env.broker_mode paper`

## Dependencies

```
gymnasium, gym-trading-env, stable-baselines3[extra], yfinance,
PyWavelets, pandas-ta, matplotlib, pandas, numpy,
pydantic, pydantic-settings, optuna, alpaca-py,
sqlalchemy, rerun-sdk, sseclient-py
```

## Optimization

```bash
just hylo-main --main.optimize true --main.optimize_config.n_trials 20
```

Optuna searches over learning rate (log-scale) and total timesteps (linear) within bounded ranges defined by `OptimizeDependent`. Uses journal-based storage for safe parallel trials.

## Competitive Positioning

Compared against FinRL (14k stars), TensorTrade (6k stars), gym-trading-env, and SB3:

**What this project does that others do not:**
- Asset auto-discovery with regime detection (no static ticker lists)
- Model staleness and data freshness gates (no other framework implements these)
- Graceful shutdown with position flattening
- Audit trail (JSONL trade log)
- Full typed pipeline orchestration with artifact store (StoreMonad)
- Wavelet denoising on all OHLCV channels
- Coalgebraic observer layer (Tail + Visualize)

**What this project does not do (by design):**
- Multi-asset simultaneous portfolio (single-asset focus; AssetIdentity supports rotation)
- Ensemble methods (single model per run)
- Custom reward functions (gym-trading-env default is the invariant)
- Slippage modeling (not yet implemented; potential future RiskDependent field)
