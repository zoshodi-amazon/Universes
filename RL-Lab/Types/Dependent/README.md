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
| `ConstraintDependent` | 3 | `stop_loss_pct > max_drawdown_pct` (MISSING) | `Types/Dependent/Constraint/default.py` | PARTIAL |
| `ExecutionDependent` | 6 | `0.0 in position_space` (MISSING) | `Types/Dependent/Execution/default.py` | PARTIAL |
| `FilterDependent` | 7 | None needed (fields independent) | `Types/Dependent/Filter/default.py` | IMPLEMENTED |
| `ThresholdDependent` | 6 | None needed (fields independent) | `Types/Dependent/Threshold/default.py` | IMPLEMENTED |
| `SearchDependent` | 7 | `lr_min < lr_max`, `budget_min < budget_max` | `Types/Dependent/Search/default.py` | IMPLEMENTED |

### ConstraintDependent (3 fields)

```lean
structure ConstraintDependent where
  stopLossPct     : Float := -2.0    -- bounded [-100, 0]
  profitThreshPct : Float := 0.5     -- bounded [0, 100]
  maxDrawdownPct  : Float := -5.0    -- bounded [-100, 0]
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Fiber closure: stop-loss must be less severe than circuit breaker. -/
def ConstraintDependent.valid (r : ConstraintDependent) : Prop :=
  r.stopLossPct > r.maxDrawdownPct

def ValidConstraintDependent := { r : ConstraintDependent // ConstraintDependent.valid r }
```

**Refactor items:**
- [ ] Add `model_validator` enforcing `stop_loss_pct > max_drawdown_pct`

### ExecutionDependent (6 fields)

```lean
structure ExecutionDependent where
  initialValue   : Float      := 10000.0  -- bounded [100, 1e8]
  feesPct        : Float      := 0.1      -- bounded [0, 10]
  borrowRatePct  : Float      := 0.0      -- bounded [0, 10]
  positionSpace  : Array Float := #[-1.0, 0.0, 1.0]  -- min 2, max 10
  executionMode  : ExecutionMode := .sim   -- EXTRACT to Inductive/
  ioExecutionKey : String     := "sim"     -- bounded [1, 256]
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Fiber closure: flat position must be available. -/
def ExecutionDependent.valid (e : ExecutionDependent) : Prop :=
  0.0 ∈ e.positionSpace

def ValidExecutionDependent := { e : ExecutionDependent // ExecutionDependent.valid e }
```

**Refactor items:**
- [ ] Extract `ExecutionMode` to `Types/Inductive/ExecutionMode/default.py`
- [ ] Add `model_validator` enforcing `0.0 in position_space`

### FilterDependent (7 fields)

```lean
structure FilterDependent where
  volumeQuantile    : Float := 30.0   -- bounded [0, 100]
  priceQuantile     : Float := 5.0    -- bounded [0, 100]
  volatilityBound   : Float := 10.0   -- bounded [0, 100]
  turnoverQuantile  : Float := 0.1    -- bounded [0, 100]
  requireInvertible : Bool  := false
  enabled           : Bool  := true
  minCatalogSize    : Nat   := 5      -- bounded [3, 1000]
  deriving Repr, Lean.ToJson, Lean.FromJson

-- No cross-field constraint needed — all fields are independent axes.
```

### ThresholdDependent (6 fields)

```lean
structure ThresholdDependent where
  minQualifyingIndices : Nat   := 3      -- bounded [1, 1000]
  maxPhaseDurationS    : Float := 300.0  -- bounded [1, 86400]
  maxIoFailures        : Nat   := 5      -- bounded [0, 100]
  maxErrorRatePct      : Float := 10.0   -- bounded [0, 100]
  notifyOnCritical     : Bool  := true
  enabled              : Bool  := true
  deriving Repr, Lean.ToJson, Lean.FromJson
```

### SearchDependent (7 fields)

```lean
structure SearchDependent where
  budget               : Nat              := 20       -- bounded [1, 10000]
  parallelism          : Nat              := 1        -- bounded [1, 16]
  objectiveMetric      : ObjectiveInductive := .winRatePct  -- EXTRACT to Inductive/
  searchSpaceLrMin     : Float            := 1e-5     -- bounded [1e-8, 1.0]
  searchSpaceLrMax     : Float            := 1e-2     -- bounded [1e-8, 1.0]
  searchSpaceBudgetMin : Nat              := 10000    -- bounded [100, 100M]
  searchSpaceBudgetMax : Nat              := 200000   -- bounded [100, 100M]
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Fiber closure: search range lower bounds must be strictly less than upper bounds. -/
def SearchDependent.valid (o : SearchDependent) : Prop :=
  o.searchSpaceLrMin < o.searchSpaceLrMax ∧
  o.searchSpaceBudgetMin < o.searchSpaceBudgetMax

def ValidSearchDependent := { o : SearchDependent // SearchDependent.valid o }
```

**Refactor items:**
- [ ] Extract `ObjectiveInductive` to `Types/Inductive/ObjectiveInductive/default.py`

## Domain Terms Projecting to Stratum 3

| Term | Area | Definition | Type Mapping | Other Strata |
|------|------|-----------|--------------|-------------|
| Stop-Loss | Constraint | Per-step loss threshold | `ConstraintDependent.stop_loss_pct` | 7 (IOEvalPhase, IOProjectPhase) |
| Take-Profit | Constraint | Per-step gain threshold | `ConstraintDependent.profit_threshold_pct` | 7 (IOEvalPhase, IOProjectPhase) |
| Drawdown Limit | Constraint | Peak-to-trough circuit breaker | `ConstraintDependent.max_drawdown_pct` | 7 (IOProjectPhase) |
| Initial Capital | Environment | Starting portfolio value | `ExecutionDependent.initial_value` | 1 (per-session), 7 (IO) |
| Trading Fee | Environment | Per-trade friction cost | `ExecutionDependent.fees_pct` | 7 (TradingEnv) |
| Borrow Rate | Environment | Short position cost | `ExecutionDependent.borrow_rate_pct` | 7 (TradingEnv) |
| Position Space | Environment | Allowed position bins | `ExecutionDependent.position_space` | 7 (TradingEnv action space) |
| Execution Mode | Execution | Sim/paper/live toggle | `ExecutionDependent.execution_mode` | 2 (ExecutionMode ADT), 7 (IOProjectPhase) |
| Filter | Market Data | Volume/price/turnover gates | `FilterDependent` | 7 (IODiscoveryPhase) |
| Signal Threshold | Observability | When to fire signals | `ThresholdDependent` | 6 (SignalMonad), 7 (IODiscoveryPhase) |
| Search Space | Search | HPO parameter ranges | `SearchDependent` | 7 (IOComposePhase + Optuna) |

## Validation Checklist (ana-compose)

- [ ] Every numeric field has both `ge` and `le` bounds
- [ ] All cross-field constraints have `model_validator` implementations
- [ ] `ConstraintDependent`: `stop_loss_pct > max_drawdown_pct`
- [ ] `ExecutionDependent`: `0.0 in position_space`
- [ ] `SearchDependent`: `lr_min < lr_max` AND `budget_min < budget_max` (already done)
- [ ] All Inductive-typed fields import from `Types/Inductive/`, not inline
- [ ] `default.json` roundtrip: `fromJson(toJson(default)) == default`
- [ ] <=7 fields per type
- [ ] Every field has `description=...`
