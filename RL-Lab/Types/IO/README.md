# Stratum 7 — IO (QGP, Deconfined)

## Lean 4 Template

```lean
-- Stratum 7: IO (QGP, deconfined)
-- Lean keyword: IO (built-in monad)
-- Space group: deconfined — all lower strata accessible. The IO executor
--   composes Identity + Inductive + Dependent + Hom + Product + Monad types
--   into an effectful computation that reads typed JSON and produces a typed Product.
-- Python realization uses dry-python/returns: IOResult[T, ErrorMonad]

import Lean.Data.Json
import Types.Identity.Default
import Types.Inductive.Default
import Types.Dependent.Default
import Types.Hom.Default
import Types.Product.Default
import Types.Monad.Default

/-- IO executor Settings: composes only lower-stratum types. No bare parameters. -/
structure IO{Phase}Phase.Settings where
  {fields : IdentityType | DependentType | HomType}
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- The morphism type: Settings → IOResult Product ErrorMonad. -/
def IO{Phase}Phase.run : Settings → IO (IOResult {Phase}ProductOutput ErrorMonad)
```

## Space Group & Closure

**Symmetry:** Deconfined (QGP). All symmetries from lower strata are accessible. The IO stratum is where effectful computation happens — external API calls, file I/O, execution, model solving. The IO executor's job is to faithfully realize the morphism `Hom → Product` through the IO monad.

**Closure conditions:**
1. Settings classes compose ONLY lower-stratum types — no bare `int`, `str`, or `float` parameters
2. Every `run()` function returns `IOResult[ProductOutput, ErrorMonad]` via `@impure_safe` (even on failure)
3. `default.json` is the serialized Settings at the IO boundary — committed like a lock file
4. No IO executor defines new types — all types live in Strata 1-6
5. Each executor is self-contained: reads its own JSON, accepts CLI overrides, no cross-phase Settings imports
6. The `do` notation (Python: sequential statements) sequences effectful operations
7. External effects (API calls, file writes) are the ONLY things that happen here — all pure computation is delegated to types in lower strata
8. `dry-python/returns` provides the monadic surface: `IOResult`, `Result`, `Maybe`, `@safe`/`@impure_safe`, `flow()`/`pipe()`

**Python realization:** `pydantic_settings.BaseSettings` subclass with `default.json` as settings source. `__main__` block for CLI entry. `run()` decorated with `@impure_safe`, returns `IOResult[ProductOutput, ErrorMonad]`.

## Implemented Executors (7 phases)

| Phase | Executor | Settings Fields | Product | File |
|-------|----------|:--------------:|---------|------|
| 1 Discovery | `IODiscoveryPhase` | 5 | `DiscoveryProductOutput` | `Types/IO/IODiscoveryPhase/default.py` |
| 2 Ingest | `IOIngestPhase` | 4 | `IngestProductOutput` | `Types/IO/IOIngestPhase/default.py` |
| 3 Transform | `IOTransformPhase` | 4 | `TransformProductOutput` | `Types/IO/IOTransformPhase/default.py` |
| 4 Solve | `IOSolvePhase` | 5 | `SolveProductOutput` | `Types/IO/IOSolvePhase/default.py` |
| 5 Eval | `IOEvalPhase` | 5 | `EvalProductOutput` | `Types/IO/IOEvalPhase/default.py` |
| 6 Project | `IOProjectPhase` | 5 | `ProjectProductOutput` | `Types/IO/IOProjectPhase/default.py` |
| 7 Compose | `IOComposePhase` | 4 | `ComposeProductOutput` | `Types/IO/IOComposePhase/default.py` |

### Settings Composition Pattern

```lean
-- Each Settings composes Identity + Dependent + Hom types:
structure IODiscoveryPhase.Settings where
  index     : IndexIdentity       := {}    -- Stratum 1
  session   : SessionIdentity     := {}    -- Stratum 1
  discovery : DiscoveryHom        := {}    -- Stratum 4
  execution : ExecutionDependent  := {}    -- Stratum 3
  store     : StoreMonad          := {}    -- Stratum 6
  deriving Repr, Lean.ToJson, Lean.FromJson

-- @impure_safe
def IODiscoveryPhase.run : Settings → IOResult DiscoveryProductOutput ErrorMonad
```

## Capability Surface — Autonomous RL Hot-Swapping Mid-Freq Trading System

### Phase Chain

```
Discovery → Ingest → Transform → Solve → Eval → Project → Compose
    1          2         3          4       5       6         7
   BEC    Crystalline  LiqCrys   Liquid   Gas    Plasma     QGP
```

### Per-Phase Capabilities

**Phase 1 — Discovery (IODiscoveryPhase)**
- yfinance catalog universe fetch OR manual index list
- Index-class routing (stock/crypto/forex by suffix)
- Quantile-based filter (volume, price, volatility, turnover, invertibility)
- Trend-score qualification with configurable threshold
- Results sorted by trend score descending (strongest trend first)
- Configurable signal thresholds (min qualifying indices, max IO failures)
- Artifact persistence to StoreMonad

**Phase 2 — Ingest (IOIngestPhase)**
- Frame download via yfinance with caching
- Calendar-to-trading-day period normalization (stock/forex: 7/5 ratio, crypto: 1.0)
- FrameInductive structural validation on all raw DataFrames
- Gap detection and forward-fill (up to 5x interval; warns on larger)
- Warmup frame trimming for indicator initialization
- Cache hit/miss tracking

**Phase 3 — Transform (IOTransformPhase)**
- Per-channel basis denoising (5 frame channels x 3 features = 15 basis features)
  - Denoised percent change (VisuShrink thresholding)
  - Approximation coefficient trend proxy (upsampled low-frequency band)
  - Detail energy (sum of squared detail coefficients, normalized)
- Trend indicator (pandas_ta, normalized to [0,1])
- Envelope direction signal (clipped to [-1,1])
- Binary regime classification (trending vs. ranging via threshold)
- NaN cleanup and transform correlation analysis
- Total: 18 features per bar

**Phase 4 — Solve (IOSolvePhase)**
- SB3 RL solving with 4 solvers (PPO, SAC, DQN, A2C)
- MlpPolicy (hardcoded for flat input space)
- Vectorized environments (SubprocVecEnv for parallel sim, DummyVecEnv otherwise)
- VecNormalize for input and signal normalization
- Reward plateau detection (std < 1e-4 in last 25% → `early_stopped = True`)
- GPU auto-detection
- Model + normalize artifacts persisted to StoreMonad

**Phase 5 — Eval (IOEvalPhase)**
- Deterministic out-of-sample rollout with solved model
- Per-step stop-loss and take-profit gates (from ConstraintDependent)
- Max drawdown tracking (peak-to-trough)
- Position flattening at episode end
- Render log saving for visualization

**Phase 6 — Project (IOProjectPhase)**
- Live bar-by-bar prediction loop with configurable sampling
- Full ingest + transform pipeline re-run per bar
- Alpaca execution integration (paper + live modes)
  - Market orders (BUY/SELL), position flips, close_position
  - Position reconciliation via `get_all_positions()`
- 8 safeguard gates: market hours, new bar, duplicate bar, max drawdown circuit breaker, artifact staleness, data staleness, insufficient bars, missing features
- Per-step stop-loss and take-profit
- SIGINT/SIGTERM graceful shutdown with position flattening
- JSONL audit logging (every position change timestamped)
- Max frames session cap

**Phase 7 — Compose (IOComposePhase)**
- Walk-forward orchestration: Discovery → Ingest → Transform → (Solve → Eval)* windowing
- Configurable stride, solve/eval split, window sizing
- Win rate computation across windows
- Reproducibility via seed setting (numpy + torch)
- **Optuna search mode**: Bayesian hyperparameter search over learning_rate and budget
  - JournalFileBackend for concurrent-safe trial storage
  - Parallel trial workers
  - Configurable objective (win_rate_pct or avg_return_pct)

### Command Surface (15 commands)

| # | Command | Type | Phase | Description |
|---|---------|------|:-----:|-------------|
| 1 | `cata-discover` | Catamorphism | 1 | Catalog + trend-score + filter discovery |
| 2 | `cata-ingest` | Catamorphism | 2 | Download + cache frame data |
| 3 | `cata-transform` | Catamorphism | 3 | Basis denoise + indicators |
| 4 | `cata-solve` | Catamorphism | 4 | RL model solving (SB3) |
| 5 | `cata-eval` | Catamorphism | 5 | Out-of-sample evaluation |
| 6 | `cata-project` | Catamorphism | 6 | Live bar-by-bar projection + execution |
| 7 | `hylo-compose` | Hylomorphism | 7 | Full pipeline + optional Optuna search |
| 8 | `ana-discover` | Anamorphism | 1' | Probe discovery artifact |
| 9 | `ana-ingest` | Anamorphism | 2' | Probe ingest artifact + blob |
| 10 | `ana-transform` | Anamorphism | 3' | Probe transform geometry |
| 11 | `ana-solve` | Anamorphism | 4' | Probe model + normalize + reward |
| 12 | `ana-eval` | Anamorphism | 5' | Probe eval return + Flask renderer |
| 13 | `ana-project` | Anamorphism | 6' | Probe audit + orders + shutdown |
| 14 | `ana-compose` | Anamorphism | 7' | Artifact probe + type validation + Rerun viz |
| 15 | `ana-check` | Anamorphism | all | Cross-cutting: imports, fields, JSON fidelity |

### External Dependency Surface

| Library | Phases | Purpose |
|---------|--------|---------|
| `yfinance` | 1, 2, 6 | Market data (catalog, frame, index info) |
| `pandas_ta` | 1, 3 | Technical indicators (trend, envelope) |
| `pywt` | 3 | Basis decomposition and denoising |
| `stable_baselines3` | 4, 5, 6 | RL solvers (PPO, SAC, DQN, A2C) |
| `gymnasium` + `gym_trading_env` | 4, 5, 6 | Trading environment simulation |
| `alpaca-trade-api` | 6 | Paper/live execution |
| `optuna` | 7 | Hyperparameter search |
| `rerun-sdk` | 7' | Cross-phase measure visualization |
| `torch` | 4, 7 | GPU detection, seed setting |
| `sqlalchemy` | all | Artifact metadata DB (StoreMonad) |
| `pydantic` + `pydantic-settings` | all | Type definitions + JSON/CLI config |
| `returns` | all | Monadic IO: IOResult, Result, Maybe, @safe, @impure_safe, flow/pipe |

### Refactor Items
- [ ] Promote `MIN_BARS` (64) and `MAX_DATA_AGE_DAYS` (7) from IOProjectPhase constants to typed fields
- [ ] Wrap all `raise` statements via `@safe`/`@impure_safe` from `dry-python/returns`
- [ ] Populate `MeasureMonad` in 5 phases that currently skip it

## Domain Terms Projecting to Stratum 7

| Term | Area | Definition | Type Mapping | Other Strata |
|------|------|-----------|--------------|-------------|
| Walk-Forward Analysis | Evaluation | Sequential solve/eval windowing | `IOComposePhase` windowing logic | 4 (ComposeHom stride/split) |
| Paper Trading | Execution | Real-time sim with live data | `IOProjectPhase` (execution_mode=paper) | 2 (ExecutionMode), 3 (ExecutionDependent) |
| Hot Swap | Infrastructure | Replace model without stopping | `IOProjectPhase` loads model by `solve_session_id` | 4 (ProjectHom.solve_session_id) |
| Circuit Breaker | Constraint | Auto-halt on drawdown breach | `IOProjectPhase` drawdown check | 3 (ConstraintDependent.max_drawdown_pct) |
| Graceful Shutdown | Infrastructure | SIGINT/SIGTERM handler | `IOProjectPhase` SHUTDOWN flag | 6 (audit logging) |
| Optuna Study | Search | Managed HPO session | `IOComposePhase` search mode | 3 (SearchDependent), 5 (ComposeProductMeta) |
| Kill Switch | Constraint | Emergency flatten-all | `IOProjectPhase` flatten on circuit breaker | 6 (SignalMonad) |
| Health Check | Observability | Component health probe | `CoIOComposePhase` import/field/JSON checks | CoTypes/ |
| Execution API | Execution | Alpaca trading interface | `IOProjectPhase` TradingClient | 2 (ExecutionMode), 3 (ExecutionDependent) |

## Validation Checklist (ana-compose)

- [ ] All Settings compose ONLY lower-stratum types (no bare parameters)
- [ ] Every `run()` returns `IOResult[ProductOutput, ErrorMonad]` via `@impure_safe`
- [ ] `default.json` exists for every IO executor and roundtrips correctly
- [ ] No cross-phase Settings imports
- [ ] Each executor has `__main__` block
- [ ] All external API calls are wrapped with `@impure_safe` → `IOResult[T, ErrorMonad]`
