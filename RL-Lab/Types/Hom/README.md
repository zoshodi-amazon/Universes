# Stratum 4 — Hom (Liquid, SO(3))

## Lean 4 Template

```lean
-- Stratum 4: Hom (Liquid, SO(3))
-- Lean keyword: structure (morphism domain) + → (arrow type)
-- Space group: full rotation — any valid input maps to a valid output.
-- Each Hom type is the domain of a morphism into its phase's IO executor.
-- The IO executor's type signature is: def run : Settings → IO ProductOutput
-- where Settings composes Hom + Identity + Dependent types.

import Lean.Data.Json
import Types.Dependent.Default   -- all Dependent types
import Types.Inductive.Default   -- all Inductive ADTs

structure {Phase}Hom where
  {fields : DependentType | InductiveType | BoundedScalar := default}
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Independence: no field derivable from another. -/
/-- Completeness: all input axes for this phase are present. -/
/-- Locality: each field belongs to this phase only; shared params in Identity/ or Dependent/. -/
```

## Space Group & Closure

**Symmetry:** SO(3). Full rotational freedom within bounded constraints. Each field is an independent generator of the morphism's input space — no field is derivable from another, and together they span the full degree of freedom for the phase.

**Closure conditions:**
1. Every field has a bounded default (the Hom is always constructible)
2. No field is derivable from another (independence / coordinate chart property)
3. All input axes for the phase are present (completeness)
4. Shared parameters live in Identity/ or Dependent/, not duplicated across Hom types (locality)
5. Inductive-typed fields import from Stratum 2
6. Dependent-typed sub-structures import from Stratum 3
7. The Hom type, combined with Identity + Dependent types, fully determines the IO executor's behavior

**Python realization:** `pydantic.BaseModel` with all fields defaulted. Composed into IO executor's `BaseSettings` class. Serialized as `default.json` at the IO boundary.

## Implemented Types

| Type | Fields | Composes | File | Status |
|------|:------:|---------|------|--------|
| `DiscoveryHom` | 7 | LiquidityDependent, AlarmDependent | `Types/Hom/Discovery/default.py` | IMPLEMENTED |
| `IngestHom` | 2 | — | `Types/Hom/Ingest/default.py` | IMPLEMENTED |
| `FeatureHom` | 7 | WaveletName*, ThresholdMode* | `Types/Hom/Feature/default.py` | PARTIAL (inline enums) |
| `TrainHom` | 7 | AlgoIdentity | `Types/Hom/Train/default.py` | IMPLEMENTED |
| `EvalHom` | 1 | — | `Types/Hom/Eval/default.py` | IMPLEMENTED |
| `ServeHom` | 5 | AlgoIdentity | `Types/Hom/Serve/default.py` | IMPLEMENTED |
| `MainHom` | 4 | OptimizeDependent | `Types/Hom/Main/default.py` | IMPLEMENTED |

*WaveletName and ThresholdMode are inline enums to be extracted to Stratum 2.

### Lean Signatures

```lean
structure DiscoveryHom where
  ioUniverse       : Array String     := #[]       -- max 10000, each [A-Z0-9\-./=]{1,16}
  screener         : String           := "most_actives"  -- [a-z_]+, 1-64 chars
  minAdx           : Float            := 20.0      -- bounded [0, 100]
  minBars          : Nat              := 360        -- bounded [1, 100000]
  adxLookbackPeriod: String           := "60d"      -- regex \d{1,4}d
  liquidity        : LiquidityDependent := {}
  alarms           : AlarmDependent     := {}
  deriving Repr, Lean.ToJson, Lean.FromJson

structure IngestHom where
  period      : String := "60d"    -- regex \d{1,4}d
  warmupBars  : Nat    := 28       -- bounded [0, 500]
  deriving Repr, Lean.ToJson, Lean.FromJson

structure FeatureHom where
  wavelet             : WaveletName   := .db4
  level               : Nat           := 4         -- bounded [1, 8]
  thresholdMode       : ThresholdMode := .soft
  adxPeriod           : Nat           := 14        -- bounded [2, 100]
  supertrendPeriod    : Nat           := 10        -- bounded [2, 100]
  supertrendMultiplier: Float         := 3.0       -- bounded [0.5, 10.0]
  regimeThreshold     : Float         := 25.0      -- bounded [0, 100]
  deriving Repr, Lean.ToJson, Lean.FromJson

structure TrainHom where
  algo              : AlgoIdentity := .ppo
  nEnvs             : Nat          := 1           -- bounded [1, 16]
  learningRate      : Float        := 3e-4        -- bounded [1e-8, 1.0]
  totalTimesteps    : Nat          := 50000       -- bounded [100, 100M]
  episodeDurationMin: Nat          := 1440        -- bounded [60, 100000]
  normalizeObs      : Bool         := true
  normalizeReward   : Bool         := true
  deriving Repr, Lean.ToJson, Lean.FromJson

structure EvalHom where
  forwardStepsMin : Nat := 1440    -- bounded [60, 100000]
  deriving Repr, Lean.ToJson, Lean.FromJson

structure ServeHom where
  trainRunId     : String         -- required, [a-f0-9]{8}
  ioAlgo         : AlgoIdentity := .ppo
  pollIntervalS  : Nat          := 60     -- bounded [5, 300]
  maxBars        : Nat          := 288    -- bounded [1, 10000]
  maxModelAgeMin : Nat          := 1440   -- bounded [1, 100000]
  deriving Repr, Lean.ToJson, Lean.FromJson

structure MainHom where
  strideMin       : Nat              := 1440   -- bounded [60, 100000]
  trainSplitPct   : Float            := 80.0   -- bounded [10, 95]
  optimize        : Bool             := false
  optimizeConfig  : OptimizeDependent := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
```

**Refactor items:**
- [ ] Extract `WaveletName` from `FeatureHom` to `Types/Inductive/WaveletName/`
- [ ] Extract `ThresholdMode` from `FeatureHom` to `Types/Inductive/ThresholdMode/`
- [ ] Add `max_length` bound to `DiscoveryHom.io_universe` list field

## Domain Terms Projecting to Stratum 4

| Term | Area | Definition | Type Mapping | Other Strata |
|------|------|-----------|--------------|-------------|
| Lookback Period | Feature Eng. | Historical bars for features | `IngestHom.period`, `DiscoveryHom.adx_lookback_period` | 7 (yfinance) |
| Learning Rate | Agent/Model | Optimizer step size | `TrainHom.learning_rate` | 3 (OptimizeDependent search bounds), 5 (TrainProductOutput, PLANNED) |
| Total Timesteps | Agent/Model | Training budget | `TrainHom.total_timesteps` | 3 (OptimizeDependent search bounds), 5 (TrainProductOutput) |
| Episode Duration | Environment | Max steps per episode | `TrainHom.episode_duration_min` | 7 (TradingEnv) |
| Wavelet Family | Feature Eng. | Signal decomposition basis | `FeatureHom.wavelet` | 2 (WaveletName ADT) |
| ADX Period | Feature Eng. | Trend indicator lookback | `FeatureHom.adx_period` | 7 (pandas_ta) |
| Polling Interval | Execution | Bar fetch cadence | `ServeHom.poll_interval_s` | 7 (IOServePhase loop) |
| Walk-Forward Stride | Evaluation | Window step size | `MainHom.stride_min` | 7 (IOMainPhase windowing) |
| Train/Test Split | Evaluation | Data partitioning ratio | `MainHom.train_split_pct` | 7 (IOMainPhase) |
| Warmup Bars | Feature Eng. | Indicator warm-up discard | `IngestHom.warmup_bars` | 7 (IOIngestPhase) |

## Validation Checklist (ana-main)

- [ ] Every field has a bounded default
- [ ] No field is derivable from another (independence)
- [ ] All Inductive-typed fields import from `Types/Inductive/`
- [ ] All Dependent-typed sub-structures import from `Types/Dependent/`
- [ ] `default.json` roundtrip: `fromJson(toJson(default)) == default`
- [ ] <=7 fields per type
- [ ] Every field has `description=...`
- [ ] No inline enums
