# CoStratum 3 — CoDependent (Liquid Crystal Dual, Cofibration)

## Lean 4 Template

```lean
-- CoStratum 3: CoDependent (Liquid Crystal dual, cofibration)
-- Lean keyword: structure (lifting property witness, all Bool fields)
-- Duality: Dependent (fibration) ↔ CoDependent (cofibration)
-- Where Dependent defines parameterized constraints (the fiber),
--   CoDependent validates that a serialized artifact inhabits the fiber.

structure Co{Name}Dependent where
  {fields : Bool := false}    -- fiber conformance probes
  deriving Repr, Lean.ToJson, Lean.FromJson
```

## Duality & Closure

**Dual of:** Stratum 3 (Dependent, indexed type families).

Where `ConstraintDependent` defines bounded parameters with cross-field constraints (the fiber over the base space), `CoConstraintDependent` validates that a deserialized instance actually satisfies those constraints. This is the **lifting property** — given a point in the base space, does the serialized data lift to a valid fiber element?

**Pattern:** All fields are `Bool`, defaulting to `False`. Each field witnesses one constraint satisfaction.

## Implemented Types

| Type | Fields | Dual Of | File |
|------|:------:|---------|------|
| `CoConstraintDependent` | 2 | `ConstraintDependent` | `CoTypes/CoDependent/Constraint/default.py` |
| `CoExecutionDependent` | 3 | `ExecutionDependent` | `CoTypes/CoDependent/Execution/default.py` |
| `CoFilterDependent` | 2 | `FilterDependent` | `CoTypes/CoDependent/Filter/default.py` |
| `CoThresholdDependent` | 2 | `ThresholdDependent` | `CoTypes/CoDependent/Threshold/default.py` |
| `CoSearchDependent` | 3 | `SearchDependent` | `CoTypes/CoDependent/Search/default.py` |

```lean
structure CoConstraintDependent where
  stopLossNegative : Bool := false   -- stop_loss_pct < 0
  profitPositive   : Bool := false   -- profit_threshold_pct > 0
  -- MISSING: stopLossAboveDrawdown (stop_loss_pct > max_drawdown_pct)
  deriving Repr, Lean.ToJson, Lean.FromJson

structure CoSearchDependent where
  lrRangeValid        : Bool := false   -- lr_min < lr_max
  timestepsRangeValid : Bool := false   -- timesteps_min < timesteps_max
  trialsPositive      : Bool := false   -- n_trials >= 1
  deriving Repr, Lean.ToJson, Lean.FromJson
```

**Refactor items:**
- [ ] Add `stop_loss_above_drawdown` field to `CoConstraintDependent` (mirrors the Stratum 3 cross-field constraint)
- [ ] Add `flat_position_available` field to `CoExecutionDependent` (mirrors `0.0 in positions` constraint)

## Validation Checklist

- [ ] 1-1 correspondence: every `Types/Dependent/{X}/` has a `CoTypes/CoDependent/{X}/`
- [ ] Every cross-field constraint in Stratum 3 has a corresponding Bool witness here
- [ ] All fields default to `False`
