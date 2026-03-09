# Stratum 7 — IO (QGP, Deconfined)

## Lean 4 Template

```lean
-- Stratum 7: IO (QGP, deconfined)
-- Lean keyword: IO (built-in monad)
-- Space group: deconfined — all lower strata accessible. The IO executor
--   composes Identity + Inductive + Dependent + Hom + Product + Monad types
--   into an effectful computation that reads typed JSON and produces a typed Product.

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

/-- The morphism type: Settings → IO Product. -/
def IO{Phase}Phase.run : Settings → IO {Phase}ProductOutput
```

## Space Group & Closure

**Symmetry:** Deconfined (QGP). All symmetries from lower strata are accessible. The IO stratum is where effectful computation happens — external API calls, file I/O, broker execution, model training. The IO executor's job is to faithfully realize the morphism `Hom → Product` through the IO monad.

**Closure conditions:**
1. Settings classes compose ONLY lower-stratum types — no bare `int`, `str`, or `float` parameters
2. Every `run()` function returns a typed `ProductOutput` (even on failure, via error Product)
3. `default.json` is the serialized Settings at the IO boundary — committed like a lock file
4. No IO executor defines new types — all types live in Strata 1-6
5. Each executor is self-contained: reads its own JSON, accepts CLI overrides, no cross-phase Settings imports
6. The `do` notation (Python: sequential statements) sequences effectful operations
7. External effects (API calls, file writes) are the ONLY things that happen here — all pure computation is delegated to types in lower strata

**Python realization:** `pydantic_settings.BaseSettings` subclass with `default.json` as settings source. `__main__` block for CLI entry. `run()` method returns `ProductOutput`.

## Implemented Executors (7 phases)

| Phase | Executor | Settings Fields | Product | File |
|-------|----------|:--------------:|---------|------|
| 1 Discovery | `IODiscoveryPhase` | 5 | `DiscoveryProductOutput` | `Types/IO/IODiscoveryPhase/default.py` |
| 2 Ingest | `IOIngestPhase` | 4 | `IngestProductOutput` | `Types/IO/IOIngestPhase/default.py` |
| 3 Feature | `IOFeaturePhase` | 4 | `FeatureProductOutput` | `Types/IO/IOFeaturePhase/default.py` |
| 4 Train | `IOTrainPhase` | 5 | `TrainProductOutput` | `Types/IO/IOTrainPhase/default.py` |
| 5 Eval | `IOEvalPhase` | 5 | `EvalProductOutput` | `Types/IO/IOEvalPhase/default.py` |
| 6 Serve | `IOServePhase` | 5 | `ServeProductOutput` | `Types/IO/IOServePhase/default.py` |
| 7 Main | `IOMainPhase` | 4 | `MainProductOutput` | `Types/IO/IOMainPhase/default.py` |

### Settings Composition Pattern

```lean
-- Each Settings composes Identity + Dependent + Hom types:
structure IODiscoveryPhase.Settings where
  asset     : AssetIdentity     := {}    -- Stratum 1
  run       : RunIdentity       := {}    -- Stratum 1
  discovery : DiscoveryHom      := {}    -- Stratum 4
  env       : EnvDependent      := {}    -- Stratum 3
  store     : StoreMonad        := {}    -- Stratum 6
  deriving Repr, Lean.ToJson, Lean.FromJson

def IODiscoveryPhase.run : Settings → IO DiscoveryProductOutput
```

## Capability Surface — Autonomous RL Hot-Swapping Mid-Freq Trading System

### Phase Chain

```
Discovery → Ingest → Feature → Train → Eval → Serve → Main
    1          2         3        4       5       6       7
   BEC    Crystalline  LiqCrys  Liquid   Gas    Plasma   QGP
```

### Per-Phase Capabilities

**Phase 1 — Discovery (IODiscoveryPhase)**
- yfinance screener universe fetch OR manual ticker list
- Asset-class routing (stock/crypto/forex by suffix)
- Percentile-based liquidity filtering (volume, price, spread, turnover, shortability)
- ADX trend qualification with configurable threshold
- Results sorted by ADX descending (strongest trend first)
- Configurable alarm thresholds (min qualifying tickers, max API failures)
- Artifact persistence to StoreMonad

**Phase 2 — Ingest (IOIngestPhase)**
- OHLCV download via yfinance with caching
- Calendar-to-trading-day period normalization (stock/forex: 7/5 ratio, crypto: 1.0)
- OHLCVInductive structural validation on all raw DataFrames
- Gap detection and forward-fill (up to 5x interval; warns on larger)
- Warmup bar trimming for indicator initialization
- Cache hit/miss tracking

**Phase 3 — Feature (IOFeaturePhase)**
- Per-channel wavelet denoising (5 OHLCV channels × 3 features = 15 wavelet features)
  - Denoised percent change (VisuShrink thresholding)
  - Approximation coefficient trend proxy (upsampled low-frequency band)
  - Detail energy (sum of squared detail coefficients, normalized)
- ADX indicator (pandas_ta, normalized to [0,1])
- SuperTrend direction signal (clipped to [-1,1])
- Binary regime classification (trending vs. ranging via ADX threshold)
- NaN cleanup and feature correlation analysis
- Total: 18 features per bar

**Phase 4 — Train (IOTrainPhase)**
- SB3 RL training with 4 algorithms (PPO, SAC, DQN, A2C)
- MlpPolicy (hardcoded for flat observation space)
- Vectorized environments (SubprocVecEnv for parallel sim, DummyVecEnv otherwise)
- VecNormalize for observation and reward normalization
- Reward plateau detection (std < 1e-4 in last 25% → `early_stopped = True`)
- GPU auto-detection
- Model + normalize artifacts persisted to StoreMonad

**Phase 5 — Eval (IOEvalPhase)**
- Deterministic out-of-sample rollout with trained model
- Per-step stop-loss and take-profit gates (from RiskDependent)
- Max drawdown tracking (peak-to-trough)
- Position flattening at episode end
- Render log saving for visualization

**Phase 6 — Serve (IOServePhase)**
- Live bar-by-bar prediction loop with configurable polling
- Full ingest + feature pipeline re-run per bar
- Alpaca broker integration (paper + live modes)
  - Market orders (BUY/SELL), position flips, close_position
  - Position reconciliation via `get_all_positions()`
- 8 safeguard gates: market hours, new bar, duplicate bar, max drawdown circuit breaker, model staleness, data staleness, insufficient bars, missing features
- Per-step stop-loss and take-profit
- SIGINT/SIGTERM graceful shutdown with position flattening
- JSONL audit logging (every position change timestamped)
- Max bars session cap

**Phase 7 — Main (IOMainPhase)**
- Walk-forward orchestration: Discovery → Ingest → Feature → (Train → Eval)* windowing
- Configurable stride, train/test split, window sizing
- Win rate computation across windows
- Reproducibility via seed setting (numpy + torch)
- **Optuna HPO mode**: Bayesian hyperparameter search over learning_rate and total_timesteps
  - JournalFileBackend for concurrent-safe trial storage
  - Parallel trial workers
  - Configurable objective (win_rate_pct or avg_return_pct)

### Command Surface (14 commands)

| # | Command | Type | Phase | Description |
|---|---------|------|:-----:|-------------|
| 1 | `cata-discover` | Catamorphism | 1 | Screener + ADX + liquidity discovery |
| 2 | `cata-ingest` | Catamorphism | 2 | Download + cache OHLCV |
| 3 | `cata-feature` | Catamorphism | 3 | Wavelet denoise + indicators |
| 4 | `cata-train` | Catamorphism | 4 | RL model training (SB3) |
| 5 | `cata-eval` | Catamorphism | 5 | Out-of-sample backtesting |
| 6 | `cata-serve` | Catamorphism | 6 | Live bar-by-bar serving + broker |
| 7 | `hylo-main` | Hylomorphism | 7 | Full pipeline + optional Optuna HPO |
| 8 | `ana-discover` | Anamorphism | 1' | Probe discovery artifact |
| 9 | `ana-ingest` | Anamorphism | 2' | Probe ingest artifact + blob |
| 10 | `ana-feature` | Anamorphism | 3' | Probe feature geometry |
| 11 | `ana-train` | Anamorphism | 4' | Probe model + normalize + reward |
| 12 | `ana-eval` | Anamorphism | 5' | Probe eval return + Flask renderer |
| 13 | `ana-serve` | Anamorphism | 6' | Probe audit + orders + shutdown |
| 14 | `ana-main` | Anamorphism | 7' | Artifact probe + type validation + Rerun viz |

### External Dependency Surface

| Library | Phases | Purpose |
|---------|--------|---------|
| `yfinance` | 1, 2, 6 | Market data (screener, OHLCV, ticker info) |
| `pandas_ta` | 1, 3 | Technical indicators (ADX, SuperTrend) |
| `pywt` | 3 | Wavelet decomposition and denoising |
| `stable_baselines3` | 4, 5, 6 | RL algorithms (PPO, SAC, DQN, A2C) |
| `gymnasium` + `gym_trading_env` | 4, 5, 6 | Trading environment simulation |
| `alpaca-trade-api` | 6 | Paper/live broker execution |
| `optuna` | 7 | Hyperparameter optimization |
| `rerun-sdk` | 7' | Cross-phase metric visualization |
| `torch` | 4, 7 | GPU detection, seed setting |
| `sqlalchemy` | all | Artifact metadata DB (StoreMonad) |
| `pydantic` + `pydantic-settings` | all | Type definitions + JSON/CLI config |

### Refactor Items
- [ ] Promote `MIN_BARS` (64) and `MAX_DATA_AGE_DAYS` (7) from IOServePhase constants to typed fields
- [ ] Wrap all 19 `raise` statements in try/except returning typed Product
- [ ] Populate `MetricMonad` in 5 phases that currently skip it

## Domain Terms Projecting to Stratum 7

| Term | Area | Definition | Type Mapping | Other Strata |
|------|------|-----------|--------------|-------------|
| Walk-Forward Analysis | Evaluation | Sequential train/test windowing | `IOMainPhase` windowing logic | 4 (MainHom stride/split) |
| Paper Trading | Execution | Real-time sim with live data | `IOServePhase` (broker_mode=paper) | 2 (BrokerMode), 3 (EnvDependent) |
| Hot Swap | Infrastructure | Replace model without stopping | `IOServePhase` loads model by `train_run_id` | 4 (ServeHom.train_run_id) |
| Circuit Breaker | Risk Mgmt | Auto-halt on drawdown breach | `IOServePhase` drawdown check | 3 (RiskDependent.max_drawdown_pct) |
| Graceful Shutdown | Infrastructure | SIGINT/SIGTERM handler | `IOServePhase` SHUTDOWN flag | 6 (audit logging) |
| Optuna Study | Optimization | Managed HPO session | `IOMainPhase` optimize mode | 3 (OptimizeDependent), 5 (MainProductMeta) |
| Kill Switch | Risk Mgmt | Emergency flatten-all | `IOServePhase` flatten on circuit breaker | 6 (AlarmMonad) |
| Health Check | Observability | Component health probe | `CoIOMainPhase` import/field/JSON checks | CoTypes/ |
| Broker API | Execution | Alpaca trading interface | `IOServePhase` TradingClient | 2 (BrokerMode), 3 (EnvDependent) |
| Scheduler | Infrastructure | Recurring job triggers | NOT IMPLEMENTED | Future: cron/systemd |
| Event Loop | Infrastructure | Async market data processing | NOT IMPLEMENTED | Future: asyncio integration |
| Rate Limiter | Infrastructure | API call throttling | NOT IMPLEMENTED | Future: IOServePhase |

## Validation Checklist (ana-main)

- [ ] All Settings compose ONLY lower-stratum types (no bare parameters)
- [ ] Every `run()` returns a typed `ProductOutput`
- [ ] `default.json` exists for every IO executor and roundtrips correctly
- [ ] No cross-phase Settings imports
- [ ] Each executor has `__main__` block
- [ ] All external API calls are wrapped with error handling → `ErrorMonad`
