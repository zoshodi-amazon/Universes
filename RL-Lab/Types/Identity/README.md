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
| `AssetIdentity` | 6 | `Types/Identity/Asset/default.py` | IMPLEMENTED |
| `RunIdentity` | 5 | `Types/Identity/Run/default.py` | IMPLEMENTED |

### AssetIdentity (6 fields)

```lean
-- The canonical asset identity — answers "what are we trading?"
-- External index: io_ticker (the IO-boundary symbol string)

inductive AssetType where
  | stock | crypto | forex
  deriving Repr, BEq, Inhabited          -- EXTRACT TO Inductive/ (currently inline)

inductive HolidayCalendar where
  | none | usMarket | bank
  deriving Repr, BEq, Inhabited          -- EXTRACT TO Inductive/ (currently inline)

inductive IntervalInductive where
  | m1 | m5 | m15 | m30 | h1 | d1
  deriving Repr, BEq, Inhabited          -- CREATE in Inductive/ (currently bare Int)

structure AssetIdentity where
  assetType     : AssetType        := .stock
  ioTicker      : String                          -- IO-boundary index, regex [A-Z0-9\-./=]{1,16}
  intervalMin   : IntervalInductive := .m5        -- REFACTOR: currently bare Int
  tradeStartMin : Nat              := 570         -- bounded [0, 1440]
  tradeEndMin   : Nat              := 960         -- bounded [0, 1440]
  holidays      : HolidayCalendar  := .usMarket
  deriving Repr, Inhabited, Lean.ToJson, Lean.FromJson

/-- Closure: market open must precede market close. -/
def AssetIdentity.valid (a : AssetIdentity) : Prop :=
  a.tradeStartMin < a.tradeEndMin

def ValidAssetIdentity := { a : AssetIdentity // AssetIdentity.valid a }
```

**Refactor items:**
- [ ] Extract `AssetType` to `Types/Inductive/AssetType/default.py`
- [ ] Extract `HolidayCalendar` to `Types/Inductive/HolidayCalendar/default.py`
- [ ] Create `IntervalInductive` ADT replacing bare `int` on `interval_min`
- [ ] Add `model_validator` enforcing `trade_start_min < trade_end_min`

### RunIdentity (5 fields)

```lean
-- The canonical run identity — answers "which execution run is this?"
-- Auto-generated: run_id is a fresh 8-char hex UUID on each construction.

structure RunIdentity where
  runId   : String  := <uuid4_hex8>    -- auto-generated, regex [a-f0-9]{8}
  runTs   : String  := <utc_now>       -- auto-generated, YYYYMMDD-HHMM
  seed    : Nat     := 42              -- bounded [0, 2^31-1]
  name    : String  := "run"           -- bounded [1,64] chars
  verbose : Nat     := 0              -- bounded {0, 1, 2}
  deriving Repr, Inhabited, Lean.ToJson, Lean.FromJson

-- No cross-field constraint needed — all fields are independent.
```

**Status:** Complete. No refactor needed.

## Domain Terms Projecting to Stratum 1

These domain terms have their **Identity stalk** (terminal object / "what exists?") at this stratum:

| Term | Area | Definition | Type Mapping | Other Strata |
|------|------|-----------|--------------|-------------|
| Asset | Market Data | A tradeable financial instrument | `AssetIdentity` | 2 (AssetType), 3 (EnvDependent), 7 (all IO) |
| Ticker | Market Data | Exchange-specific symbol identifier | `AssetIdentity.io_ticker` | 7 (yfinance/Alpaca API) |
| Run | Persistence | A unique pipeline execution instance | `RunIdentity` | 5 (Product.run_id), 6 (StoreMonad), 7 (IO) |
| Seed | Agent/Model | Random seed for reproducibility | `RunIdentity.seed` | 4 (TrainHom), 7 (IOMainPhase) |
| Interval | Market Data | Bar resolution / temporal granularity | `AssetIdentity.interval_min` | 2 (IntervalInductive, PLANNED) |
| Market Calendar | Market Data | Trading session schedule per exchange | `AssetIdentity.holidays` | 2 (HolidayCalendar), 7 (IOServePhase) |
| Market Clock | Market Data | Real-time open/closed indicator | `AssetIdentity.trade_start_min/trade_end_min` | 7 (IOServePhase._is_market_open) |
| Universe | Market Data | The set of all tradeable symbols | `DiscoveryHom.io_universe` (Stratum 4) | 1 (AssetIdentity per ticker), 5 (DiscoveryProductOutput.qualifying_tickers) |
| Initial Capital | Environment | Starting portfolio value | `EnvDependent.initial_value` (Stratum 3) | 5 (portfolio tracking), 7 (IO) |

## Validation Checklist (ana-main)

- [ ] All fields have `Field(default=..., ge=..., le=...)` or equivalent bounds
- [ ] `AssetIdentity.trade_start_min < trade_end_min` enforced by `model_validator`
- [ ] No `Optional` / `None` fields
- [ ] `default.json` roundtrip: `fromJson(toJson(default)) == default`
- [ ] <=7 fields per type
- [ ] Every field has `description=...`
- [ ] No inline enums (all extracted to `Types/Inductive/`)
