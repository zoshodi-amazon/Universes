# Stratum 3 — Dependent (Liquid Crystal, Partial SO(3))

## Lean 4 Template

```lean
-- Stratum 3: Dependent (Liquid Crystal, partial SO(3))
-- Lean keyword: structure + Subtype (Σ-type with fiber constraint)
-- Space group: parameterized but constrained. Fields are indexed by Inductive
--   ADTs from Stratum 2. Cross-field propositions seal the fiber at each point
--   of the base space.

import Lean.Data.Json
import Types.Inductive.Default  -- imports all Inductive ADTs

structure {Name}Dependent where
  {fields : InductiveType | BoundedNumeric := default}
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Fibration closure: cross-field constraints that seal the parameter fiber. -/
def {Name}Dependent.valid (x : {Name}Dependent) : Prop :=
  {conjunction: min < max, invariant holds, etc.}

/-- The closed type: only valid inhabitants exist. -/
def Valid{Name}Dependent := { x : {Name}Dependent // {Name}Dependent.valid x }
```

## Space Group & Closure

**Symmetry:** Partial SO(3). Parameterized but constrained — degrees of freedom exist but are bounded and cross-constrained. The Dependent stratum represents **indexed type families**: types whose valid inhabitants depend on the values of other fields or on Inductive indices.

**Closure conditions:**
1. Every numeric field has `ge` AND `le` bounds (no unbounded parameters)
2. Cross-field constraints enforced by `model_validator` (e.g., `min < max`)
3. Fields indexed by Inductive ADTs use proper Enum types (not bare strings)
4. Every cross-field invariant is expressible as a `Prop` in Lean / a `model_validator` in Python
5. Default-constructed value satisfies all constraints (the zero-section of the fiber is valid)

**Python realization:** `pydantic.BaseModel` with `Field(ge=..., le=...)` on all numerics, `@model_validator(mode="after")` for cross-field constraints. Inductive fields typed as `Enum` imports from Stratum 2.

## Implemented Types

| Type | Fields | Cross-Field Constraint | File | Status |
|------|:------:|----------------------|------|--------|
| `RiskDependent` | 3 | `stop_loss_pct > max_drawdown_pct` (MISSING) | `Types/Dependent/Risk/default.py` | PARTIAL |
| `EnvDependent` | 6 | `0.0 in positions` (MISSING) | `Types/Dependent/Env/default.py` | PARTIAL |
| `LiquidityDependent` | 7 | None needed (fields independent) | `Types/Dependent/Liquidity/default.py` | IMPLEMENTED |
| `AlarmDependent` | 6 | None needed (fields independent) | `Types/Dependent/Alarm/default.py` | IMPLEMENTED |
| `OptimizeDependent` | 7 | `lr_min < lr_max`, `timesteps_min < timesteps_max` | `Types/Dependent/Optimize/default.py` | IMPLEMENTED |

### RiskDependent (3 fields)

```lean
structure RiskDependent where
  stopLossPct     : Float := -2.0    -- bounded [-100, 0]
  profitThreshPct : Float := 0.5     -- bounded [0, 100]
  maxDrawdownPct  : Float := -5.0    -- bounded [-100, 0]
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Fiber closure: stop-loss must be less severe than circuit breaker. -/
def RiskDependent.valid (r : RiskDependent) : Prop :=
  r.stopLossPct > r.maxDrawdownPct

def ValidRiskDependent := { r : RiskDependent // RiskDependent.valid r }
```

**Refactor items:**
- [ ] Add `model_validator` enforcing `stop_loss_pct > max_drawdown_pct`

### EnvDependent (6 fields)

```lean
structure EnvDependent where
  initialValue  : Float      := 10000.0  -- bounded [100, 1e8]
  feesPct       : Float      := 0.1      -- bounded [0, 10]
  borrowRatePct : Float      := 0.0      -- bounded [0, 10]
  positions     : Array Float := #[-1.0, 0.0, 1.0]  -- min 2, max 10
  brokerMode    : BrokerMode := .sim     -- EXTRACT to Inductive/
  ioBrokerKey   : String     := "sim"    -- bounded [1, 256]
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Fiber closure: flat position must be available. -/
def EnvDependent.valid (e : EnvDependent) : Prop :=
  0.0 ∈ e.positions

def ValidEnvDependent := { e : EnvDependent // EnvDependent.valid e }
```

**Refactor items:**
- [ ] Extract `BrokerMode` to `Types/Inductive/BrokerMode/default.py`
- [ ] Add `model_validator` enforcing `0.0 in positions`

### LiquidityDependent (7 fields)

```lean
structure LiquidityDependent where
  minVolumePercentile : Float := 30.0   -- bounded [0, 100]
  minPricePercentile  : Float := 5.0    -- bounded [0, 100]
  maxSpreadPct        : Float := 10.0   -- bounded [0, 100]
  minTurnoverPct      : Float := 0.1    -- bounded [0, 100]
  requireShortable    : Bool  := false
  enabled             : Bool  := true
  minUniverseSize     : Nat   := 5      -- bounded [3, 1000]
  deriving Repr, Lean.ToJson, Lean.FromJson

-- No cross-field constraint needed — all fields are independent axes.
```

### AlarmDependent (6 fields)

```lean
structure AlarmDependent where
  minQualifyingTickers : Nat   := 3      -- bounded [1, 1000]
  maxPhaseDurationS    : Float := 300.0  -- bounded [1, 86400]
  maxApiFailures       : Nat   := 5      -- bounded [0, 100]
  maxErrorRatePct      : Float := 10.0   -- bounded [0, 100]
  notifyOnCritical     : Bool  := true
  enabled              : Bool  := true
  deriving Repr, Lean.ToJson, Lean.FromJson
```

### OptimizeDependent (7 fields)

```lean
structure OptimizeDependent where
  nTrials              : Nat           := 20       -- bounded [1, 10000]
  nParallel            : Nat           := 1        -- bounded [1, 16]
  objectiveMetric      : ObjectiveMetric := .winRatePct  -- EXTRACT to Inductive/
  searchSpaceLrMin     : Float         := 1e-5     -- bounded [1e-8, 1.0]
  searchSpaceLrMax     : Float         := 1e-2     -- bounded [1e-8, 1.0]
  searchSpaceTimestepsMin : Nat        := 10000    -- bounded [100, 100M]
  searchSpaceTimestepsMax : Nat        := 200000   -- bounded [100, 100M]
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Fiber closure: search range lower bounds must be strictly less than upper bounds. -/
def OptimizeDependent.valid (o : OptimizeDependent) : Prop :=
  o.searchSpaceLrMin < o.searchSpaceLrMax ∧
  o.searchSpaceTimestepsMin < o.searchSpaceTimestepsMax

def ValidOptimizeDependent := { o : OptimizeDependent // OptimizeDependent.valid o }
```

**Refactor items:**
- [ ] Extract `ObjectiveMetric` to `Types/Inductive/ObjectiveMetric/default.py`

## Domain Terms Projecting to Stratum 3

| Term | Area | Definition | Type Mapping | Other Strata |
|------|------|-----------|--------------|-------------|
| Stop-Loss | Risk Mgmt | Per-step loss threshold | `RiskDependent.stop_loss_pct` | 7 (IOEvalPhase, IOServePhase) |
| Take-Profit | Risk Mgmt | Per-step gain threshold | `RiskDependent.profit_threshold_pct` | 7 (IOEvalPhase, IOServePhase) |
| Drawdown Limit | Risk Mgmt | Peak-to-trough circuit breaker | `RiskDependent.max_drawdown_pct` | 7 (IOServePhase) |
| Initial Capital | Environment | Starting portfolio value | `EnvDependent.initial_value` | 1 (per-run), 7 (IO) |
| Trading Fee | Environment | Per-trade friction cost | `EnvDependent.fees_pct` | 7 (TradingEnv) |
| Borrow Rate | Environment | Short position cost | `EnvDependent.borrow_rate_pct` | 7 (TradingEnv) |
| Position Set | Environment | Allowed position bins | `EnvDependent.positions` | 7 (TradingEnv action space) |
| Broker Mode | Execution | Sim/paper/live toggle | `EnvDependent.broker_mode` | 2 (BrokerMode ADT), 7 (IOServePhase) |
| Liquidity Filter | Market Data | Volume/price/turnover gates | `LiquidityDependent` | 7 (IODiscoveryPhase) |
| Alarm Threshold | Observability | When to fire alerts | `AlarmDependent` | 6 (AlarmMonad), 7 (IODiscoveryPhase) |
| Search Space | Optimization | HPO parameter ranges | `OptimizeDependent` | 7 (IOMainPhase + Optuna) |
| Slippage Params | Microstructure | Market impact coefficients | NOT IMPLEMENTED | Future: `SlippageDependent` |
| Risk Budget | Risk Mgmt | Total risk allocation | NOT IMPLEMENTED | Future: `RiskDependent` extension |
| Position Limit | Position Mgmt | Max single position size | NOT IMPLEMENTED | Future: `RiskDependent` or new type |
| Daily Loss Limit | Risk Mgmt | Max loss per day before halt | NOT IMPLEMENTED | Future: `RiskDependent` extension |

## Validation Checklist (ana-main)

- [ ] Every numeric field has both `ge` and `le` bounds
- [ ] All cross-field constraints have `model_validator` implementations
- [ ] `RiskDependent`: `stop_loss_pct > max_drawdown_pct`
- [ ] `EnvDependent`: `0.0 in positions`
- [ ] `OptimizeDependent`: `lr_min < lr_max` AND `timesteps_min < timesteps_max` (already done)
- [ ] All Inductive-typed fields import from `Types/Inductive/`, not inline
- [ ] `default.json` roundtrip: `fromJson(toJson(default)) == default`
- [ ] <=7 fields per type
- [ ] Every field has `description=...`
