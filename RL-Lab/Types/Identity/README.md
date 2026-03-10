# Stratum 1 — Identity (BEC, Trivial Group {e})

## Lean 4 Template

```lean
-- Stratum 1: Identity (BEC, trivial {e})
-- Lean keyword: structure + Inhabited
-- Space group: trivial — one canonical inhabitant per external index.
-- Every field has a bounded default. The default value IS the canonical inhabitant.
-- Inhabited derivation guarantees construction never fails.

import Lean.Data.Json

structure {Name}Identity where
  {fields with bounded defaults}
  deriving Repr, Inhabited, Lean.ToJson, Lean.FromJson

/-- Closure proposition: cross-field constraints that seal the trivial group. -/
def {Name}Identity.valid (x : {Name}Identity) : Prop :=
  {conjunction of field constraints}

/-- The closed type: only valid inhabitants exist. -/
def Valid{Name}Identity := { x : {Name}Identity // {Name}Identity.valid x }
```

## Space Group & Closure

**Symmetry:** Trivial group {e}. One canonical inhabitant per external index. No continuous degrees of freedom beyond the bounded defaults. The Identity stratum represents terminal objects — types that answer "what exists?" with exactly one answer per configuration.

**Closure conditions:**
1. Every field has a bounded default (no construction failure possible)
2. All cross-field constraints are enforced by `model_validator`
3. No field is derivable from another (coordinate chart independence)
4. `Inhabited` is derivable (the default-constructed value is always valid)

**Python realization:** `pydantic.BaseModel` with all fields having `Field(default=..., ge=..., le=...)`. Cross-field constraints via `@model_validator(mode="after")`.

## Implemented Types

| Type | Fields | File | Status |
|------|:------:|------|--------|
| `IndexIdentity` | 6 | `Types/Identity/Index/default.py` | IMPLEMENTED |
| `SessionIdentity` | 5 | `Types/Identity/Session/default.py` | IMPLEMENTED |

### IndexIdentity (6 fields)

```lean
-- The canonical index identity — answers "what are we trading?"
-- External index: io_ticker (the IO-boundary symbol string)

inductive IndexClass where
  | stock | crypto | forex
  deriving Repr, BEq, Inhabited          -- EXTRACT TO Inductive/ (currently inline)

inductive TemporalMask where
  | none | usMarket | bank
  deriving Repr, BEq, Inhabited          -- EXTRACT TO Inductive/ (currently inline)

inductive IntervalInductive where
  | m1 | m5 | m15 | m30 | h1 | d1
  deriving Repr, BEq, Inhabited          -- CREATE in Inductive/ (currently bare Int)

structure IndexIdentity where
  indexClass     : IndexClass       := .stock
  ioTicker       : String                          -- IO-boundary index, regex [A-Z0-9\-./=]{1,16}
  intervalMin    : IntervalInductive := .m5        -- REFACTOR: currently bare Int
  tradeStartMin  : Nat              := 570         -- bounded [0, 1440]
  tradeEndMin    : Nat              := 960         -- bounded [0, 1440]
  holidays       : TemporalMask     := .usMarket
  deriving Repr, Inhabited, Lean.ToJson, Lean.FromJson

/-- Closure: market open must precede market close. -/
def IndexIdentity.valid (a : IndexIdentity) : Prop :=
  a.tradeStartMin < a.tradeEndMin

def ValidIndexIdentity := { a : IndexIdentity // IndexIdentity.valid a }
```

**Refactor items:**
- [ ] Extract `IndexClass` to `Types/Inductive/IndexClass/default.py`
- [ ] Extract `TemporalMask` to `Types/Inductive/TemporalMask/default.py`
- [ ] Create `IntervalInductive` ADT replacing bare `int` on `interval_min`
- [ ] Add `model_validator` enforcing `trade_start_min < trade_end_min`

### SessionIdentity (5 fields)

```lean
-- The canonical session identity — answers "which execution session is this?"
-- Auto-generated: session_id is a fresh 8-char hex UUID on each construction.

structure SessionIdentity where
  sessionId : String  := <uuid4_hex8>    -- auto-generated, regex [a-f0-9]{8}
  sessionTs : String  := <utc_now>       -- auto-generated, YYYYMMDD-HHMM
  seed      : Nat     := 42              -- bounded [0, 2^31-1]
  label     : String  := "session"       -- bounded [1,64] chars
  verbose   : Nat     := 0              -- bounded {0, 1, 2}
  deriving Repr, Inhabited, Lean.ToJson, Lean.FromJson

-- No cross-field constraint needed — all fields are independent.
```

**Status:** Complete. No refactor needed.

## Domain Terms Projecting to Stratum 1

These domain terms have their **Identity stalk** (terminal object / "what exists?") at this stratum:

| Term | Area | Definition | Type Mapping | Other Strata |
|------|------|-----------|--------------|-------------|
| Index | Market Data | A tradeable financial instrument | `IndexIdentity` | 2 (IndexClass), 3 (ExecutionDependent), 7 (all IO) |
| Ticker | Market Data | Exchange-specific symbol identifier | `IndexIdentity.io_ticker` | 7 (yfinance/Alpaca API) |
| Session | Persistence | A unique pipeline execution instance | `SessionIdentity` | 5 (Product.session_id), 6 (StoreMonad), 7 (IO) |
| Seed | Agent/Model | Random seed for reproducibility | `SessionIdentity.seed` | 4 (SolveHom), 7 (IOComposePhase) |
| Interval | Market Data | Bar resolution / temporal granularity | `IndexIdentity.interval_min` | 2 (IntervalInductive, PLANNED) |
| Market Calendar | Market Data | Trading session schedule per exchange | `IndexIdentity.holidays` | 2 (TemporalMask), 7 (IOProjectPhase) |
| Market Clock | Market Data | Real-time open/closed indicator | `IndexIdentity.trade_start_min/trade_end_min` | 7 (IOProjectPhase._is_market_open) |
| Universe | Market Data | The set of all tradeable symbols | `DiscoveryHom.io_indices` (Stratum 4) | 1 (IndexIdentity per ticker), 5 (DiscoveryProductOutput.qualifying_indices) |
| Initial Capital | Environment | Starting portfolio value | `ExecutionDependent.initial_value` (Stratum 3) | 5 (portfolio tracking), 7 (IO) |

## Validation Checklist (ana-compose)

- [ ] All fields have `Field(default=..., ge=..., le=...)` or equivalent bounds
- [ ] `IndexIdentity.trade_start_min < trade_end_min` enforced by `model_validator`
- [ ] No `Optional` / `None` fields
- [ ] `default.json` roundtrip: `fromJson(toJson(default)) == default`
- [ ] <=7 fields per type
- [ ] Every field has `description=...`
- [ ] No inline enums (all extracted to `Types/Inductive/`)
