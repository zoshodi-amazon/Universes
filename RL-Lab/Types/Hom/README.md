# Stratum 4 — Hom (Liquid, SO(3))

## Lean 4 Template

```lean
-- Stratum 4: Hom (Liquid, SO(3))
-- Lean keyword: structure (morphism domain) + → (arrow type)
-- Space group: full rotation — any valid input maps to a valid output.
-- Each Hom type is the domain of a morphism into its phase's IO executor.
-- The IO executor's type signature is: def run : Settings → IO (IOResult ProductOutput ErrorMonad)

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
| `DiscoveryHom` | 7 | FilterDependent, ThresholdDependent | `Types/Hom/Discovery/default.py` | IMPLEMENTED |
| `IngestHom` | 2 | — | `Types/Hom/Ingest/default.py` | IMPLEMENTED |
| `TransformHom` | 7 | BasisInductive*, ThresholdMode* | `Types/Hom/Transform/default.py` | PARTIAL (inline enums) |
| `SolveHom` | 7 | SolverInductive | `Types/Hom/Solve/default.py` | IMPLEMENTED |
| `EvalHom` | 1 | — | `Types/Hom/Eval/default.py` | IMPLEMENTED |
| `ProjectHom` | 5 | SolverInductive | `Types/Hom/Project/default.py` | IMPLEMENTED |
| `ComposeHom` | 4 | SearchDependent | `Types/Hom/Compose/default.py` | IMPLEMENTED |

*BasisInductive and ThresholdMode are inline enums to be extracted to Stratum 2.

### Lean Signatures

```lean
structure DiscoveryHom where
  ioIndices        : Array String     := #[]       -- max 10000, each [A-Z0-9\-./=]{1,16}
  catalogSource    : String           := "most_actives"  -- [a-z_]+, 1-64 chars
  minTrendScore    : Float            := 20.0      -- bounded [0, 100]
  minFrameLength   : Nat              := 360        -- bounded [1, 100000]
  trendLookback    : String           := "60d"      -- regex \d{1,4}d
  filter           : FilterDependent  := {}
  thresholds       : ThresholdDependent := {}
  deriving Repr, Lean.ToJson, Lean.FromJson

structure IngestHom where
  period       : String := "60d"    -- regex \d{1,4}d
  warmupFrames : Nat    := 28       -- bounded [0, 500]
  deriving Repr, Lean.ToJson, Lean.FromJson

structure TransformHom where
  basis              : BasisInductive  := .db4
  level              : Nat             := 4         -- bounded [1, 8]
  thresholdMode      : ThresholdMode   := .soft
  trendPeriod        : Nat             := 14        -- bounded [2, 100]
  envelopePeriod     : Nat             := 10        -- bounded [2, 100]
  envelopeMultiplier : Float           := 3.0       -- bounded [0.5, 10.0]
  regimeThreshold    : Float           := 25.0      -- bounded [0, 100]
  deriving Repr, Lean.ToJson, Lean.FromJson

structure SolveHom where
  solver          : SolverInductive := .ppo
  nParallel       : Nat             := 1           -- bounded [1, 16]
  learningRate    : Float           := 3e-4        -- bounded [1e-8, 1.0]
  budget          : Nat             := 50000       -- bounded [100, 100M]
  horizonMin      : Nat             := 1440        -- bounded [60, 100000]
  normalizeInput  : Bool            := true
  normalizeSignal : Bool            := true
  deriving Repr, Lean.ToJson, Lean.FromJson

structure EvalHom where
  horizonMin : Nat := 1440    -- bounded [60, 100000]
  deriving Repr, Lean.ToJson, Lean.FromJson

structure ProjectHom where
  solveSessionId  : String            -- required, [a-f0-9]{8}
  ioSolver        : SolverInductive := .ppo
  sampleIntervalS : Nat             := 60     -- bounded [5, 300]
  maxFrames       : Nat             := 288    -- bounded [1, 10000]
  maxArtifactAgeMin : Nat           := 1440   -- bounded [1, 100000]
  deriving Repr, Lean.ToJson, Lean.FromJson

structure ComposeHom where
  strideMin     : Nat              := 1440   -- bounded [60, 100000]
  solveSplitPct : Float            := 80.0   -- bounded [10, 95]
  search        : Bool             := false
  searchFiber   : SearchDependent  := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
```

**Refactor items:**
- [ ] Extract `BasisInductive` from `TransformHom` to `Types/Inductive/BasisInductive/`
- [ ] Extract `ThresholdMode` from `TransformHom` to `Types/Inductive/ThresholdMode/`
- [ ] Add `max_length` bound to `DiscoveryHom.io_indices` list field

## Domain Terms Projecting to Stratum 4

| Term | Area | Definition | Type Mapping | Other Strata |
|------|------|-----------|--------------|-------------|
| Lookback Period | Transform Eng. | Historical frames for features | `IngestHom.period`, `DiscoveryHom.trend_lookback` | 7 (yfinance) |
| Learning Rate | Agent/Model | Optimizer step size | `SolveHom.learning_rate` | 3 (SearchDependent search bounds), 5 (SolveProductOutput, PLANNED) |
| Budget | Agent/Model | Solving budget (timesteps) | `SolveHom.budget` | 3 (SearchDependent search bounds), 5 (SolveProductOutput) |
| Horizon | Environment | Max steps per episode | `SolveHom.horizon_min` | 7 (TradingEnv) |
| Basis Family | Transform Eng. | Signal decomposition basis | `TransformHom.basis` | 2 (BasisInductive ADT) |
| Trend Period | Transform Eng. | Trend indicator lookback | `TransformHom.trend_period` | 7 (pandas_ta) |
| Sample Interval | Execution | Bar fetch cadence | `ProjectHom.sample_interval_s` | 7 (IOProjectPhase loop) |
| Walk-Forward Stride | Evaluation | Window step size | `ComposeHom.stride_min` | 7 (IOComposePhase windowing) |
| Solve/Eval Split | Evaluation | Data partitioning ratio | `ComposeHom.solve_split_pct` | 7 (IOComposePhase) |
| Warmup Frames | Transform Eng. | Indicator warm-up discard | `IngestHom.warmup_frames` | 7 (IOIngestPhase) |

## Validation Checklist (ana-compose)

- [ ] Every field has a bounded default
- [ ] No field is derivable from another (independence)
- [ ] All Inductive-typed fields import from `Types/Inductive/`
- [ ] All Dependent-typed sub-structures import from `Types/Dependent/`
- [ ] `default.json` roundtrip: `fromJson(toJson(default)) == default`
- [ ] <=7 fields per type
- [ ] Every field has `description=...`
- [ ] No inline enums
