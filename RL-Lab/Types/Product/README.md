# Stratum 5 — Product (Gas, E(3))

## Lean 4 Template

```lean
-- Stratum 5: Product (Gas, E(3))
-- Lean keyword: structure (A × B)
-- Space group: Euclidean — expanding, observable. Every computable result has
--   a typed field. No information escapes into untyped channels.
-- Split into Output (codomain of the phase morphism) and Meta (observability).

import Lean.Data.Json
import Types.Monad.Default       -- ObservabilityMonad, ErrorMonad, etc.
import Types.Inductive.Default   -- AlgoIdentity, etc.

structure {Phase}ProductOutput where
  runId : String                  -- [a-f0-9]{8}
  {domain-specific output fields}
  meta  : {Phase}ProductMeta
  deriving Repr, Lean.ToJson, Lean.FromJson

structure {Phase}ProductMeta where
  obs : ObservabilityMonad := {}
  {domain-specific meta fields}
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Completeness: no computed value in the IO executor escapes untyped. -/
```

## Space Group & Closure

**Symmetry:** E(3) — full Euclidean group. Expanding, observable. The Product stratum captures everything the phase computed. Every value that the IO executor calculates must have a typed field in either Output (the result) or Meta (observability data).

**Closure conditions:**
1. Every computable result has a typed field in Output or Meta
2. No computed value in the IO executor is logged to stdout but not captured in a typed field
3. Output fields have no defaults (they MUST be populated by the IO executor)
4. Meta fields have defaults (stubs until populated)
5. Every Meta embeds `ObservabilityMonad` for uniform error/metric/alarm aggregation
6. Output × Meta = full Product for the phase (the 1-1-1 invariant)

**Python realization:** `pydantic.BaseModel`. Output classes have required fields (no defaults for domain data). Meta classes embed `ObservabilityMonad` initialized with the phase's `PhaseId`.

## Implemented Types (14 = 7 Output + 7 Meta)

| Phase | Output | Output Fields | Meta | Meta Fields | Status |
|-------|--------|:------------:|------|:-----------:|--------|
| Discovery | `DiscoveryProductOutput` | 5 | `DiscoveryProductMeta` | 6 | IMPLEMENTED |
| Ingest | `IngestProductOutput` | 5 | `IngestProductMeta` | 6 | IMPLEMENTED |
| Feature | `FeatureProductOutput` | 5 | `FeatureProductMeta` | 5 | IMPLEMENTED |
| Train | `TrainProductOutput` | 5 | `TrainProductMeta` | 6 | IMPLEMENTED |
| Eval | `EvalProductOutput` | 6 | `EvalProductMeta` | 6 | IMPLEMENTED |
| Serve | `ServeProductOutput` | 7 | `ServeProductMeta` | 6 | PARTIAL |
| Main | `MainProductOutput` | 7 | `MainProductMeta` | 5 | IMPLEMENTED |

### Key Lean Signatures

```lean
structure TrainProductOutput where
  runId          : String           -- [a-f0-9]{8}
  algo           : AlgoIdentity
  totalTimesteps : Nat              -- bounded [1, 100M]
  finalReward    : Float            -- bounded [-1e6, 1e6]
  meta           : TrainProductMeta
  deriving Repr, Lean.ToJson, Lean.FromJson

structure TrainProductMeta where
  obs              : ObservabilityMonad := {}
  episodesCompleted: Nat    := 0        -- bounded [0, 1M]
  meanEpisodeReward: Float  := 0.0      -- bounded [-1e9, 1e9]
  stdEpisodeReward : Float  := 0.0      -- bounded [0, 1e9]
  earlyStopped     : Bool   := false
  gpuUsed          : Bool   := false
  deriving Repr, Lean.ToJson, Lean.FromJson

structure ServeProductOutput where
  runId             : String          -- [a-f0-9]{8}
  ioTicker          : String          -- [A-Z0-9\-./=]{1,16}
  nBarsServed       : Nat             -- bounded [0, 10000]
  portfolioReturnPct: Float           -- bounded [-100, 1000]
  positionTaken     : Float           -- bounded [-10, 10]
  status            : ServeStatus     -- EXTRACT to Inductive/
  meta              : ServeProductMeta
  deriving Repr, Lean.ToJson, Lean.FromJson

structure MainProductOutput where
  runId      : String                  -- [a-f0-9]{8}
  nWindows   : Nat                     -- bounded [0, 10000]
  winRatePct : Float                   -- bounded [0, 100]
  durationS  : Float                   -- bounded [0, 86400]
  status     : MainStatus              -- EXTRACT to Inductive/
  results    : Array EvalProductOutput -- bounded max 10000
  meta       : MainProductMeta
  deriving Repr, Lean.ToJson, Lean.FromJson
```

**Refactor items:**
- [ ] Extract `ServeStatus` from `ServeProductOutput` to `Types/Inductive/ServeStatus/`
- [ ] Extract `MainStatus` from `MainProductOutput` to `Types/Inductive/MainStatus/`
- [ ] Add `learning_rate : Float` to `TrainProductOutput` (Optuna traceability)
- [ ] Add `max_drawdown_pct : Float` to `ServeProductMeta` (circuit breaker observation)
- [ ] Add `data_age_days : Float` and `model_age_min : Float` to `ServeProductMeta` (staleness observation)

## Domain Terms Projecting to Stratum 5

| Term | Area | Definition | Type Mapping | Other Strata |
|------|------|-----------|--------------|-------------|
| Qualifying Tickers | Market Data | Tickers passing all filters | `DiscoveryProductOutput.qualifying_tickers` | 1 (AssetIdentity per ticker) |
| Final Reward | Agent/Model | Last training reward | `TrainProductOutput.final_reward` | 7 (SB3 training) |
| Win Rate | Evaluation | % windows meeting threshold | `MainProductOutput.win_rate_pct` | 7 (IOMainPhase) |
| Portfolio Return | Evaluation | Cumulative session return | `ServeProductOutput.portfolio_return_pct` | 7 (IOServePhase) |
| Maximum Drawdown | Evaluation | Peak-to-trough decline | `EvalProductMeta.max_drawdown_pct` | 3 (RiskDependent limit) |
| Equity Curve | Evaluation | Time series of portfolio value | `EvalProductOutput.results` (via MainProductOutput) | 7 (IOEvalPhase) |
| Orders Filled | Execution | Confirmed fill count | `ServeProductMeta.orders_filled` | 7 (IOServePhase broker) |
| Broker Failures | Observability | Failed API call count | `ServeProductMeta.broker_failures` | 6 (ErrorMonad) |
| Episodes Completed | Agent/Model | Training episode count | `TrainProductMeta.episodes_completed` | 7 (SB3 training) |
| Sharpe Ratio | Evaluation | Risk-adjusted return metric | NOT IMPLEMENTED | Future: `EvalProductMeta` |
| Annualized Return | Evaluation | Geometric mean annual return | NOT IMPLEMENTED | Future: `EvalProductOutput` |
| Profit Factor | Evaluation | Gross profits / gross losses | NOT IMPLEMENTED | Future: `EvalProductMeta` |

## Validation Checklist (ana-main)

- [ ] Every computed value in each IO executor has a corresponding typed field
- [ ] No `print()` or `logger.info()` of computed values without a typed field capturing them
- [ ] All Output fields have bounds
- [ ] Every Meta embeds `ObservabilityMonad` initialized with correct `PhaseId`
- [ ] `default.json` roundtrip closure
- [ ] <=7 fields per type
- [ ] Every field has `description=...`
- [ ] No inline enums (ServeStatus, MainStatus extracted to Stratum 2)
