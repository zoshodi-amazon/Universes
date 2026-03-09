# Stratum 2 — Inductive (Crystalline, Space Group)

## Lean 4 Template

```lean
-- Stratum 2: Inductive (Crystalline, space group)
-- Lean keyword: inductive
-- Space group: rigid — finite constructors, exhaustive pattern matching.
-- The compiler rejects any match that doesn't cover all constructors.
-- No continuous degrees of freedom. Every inhabitant is a named constructor.

import Lean.Data.Json

inductive {Name}Inductive where
  | c₁ | c₂ | ... | cₙ
  deriving Repr, BEq, Inhabited

/-- JSON serialization: exhaustive matching, catch-all error. -/
instance : Lean.ToJson {Name}Inductive where
  toJson | .c₁ => "c1" | .c₂ => "c2" | ... | .cₙ => "cn"

instance : Lean.FromJson {Name}Inductive where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "c1" => pure .c₁ | "c2" => pure .c₂ | ... | "cn" => pure .cₙ
    | _ => throw s!"unknown {Name}Inductive: {s}"
```

## Space Group & Closure

**Symmetry:** Crystalline space group. Finite, rigid, exhaustive. Each Inductive type is a **closed sum** — the set of constructors is fixed at compile time and the compiler enforces exhaustive matching. Adding a constructor is a **symmetry-breaking event** (the space group changes).

**Closure conditions:**
1. Every finite variant in the domain is an `inductive` ADT — no inline `Literal["a","b"]` or bare `str` enums outside this stratum
2. Every `match`/`case` on an Inductive type covers all constructors (compiler-enforced in Lean, runtime-enforced in Python via `Enum`)
3. JSON serialization is exhaustive with a catch-all error (no silent fallthrough)
4. `BEq` is derivable (constructors are decidably equal)
5. `Inhabited` is derivable (there exists a default constructor)

**Python realization:** `class Name(str, Enum)` with exhaustive variants. The `str` mixin enables JSON serialization. `Enum` enforces finite constructors.

**Anti-pattern:** `Literal["a", "b", "c"]` anywhere in the codebase. Every such usage must be extracted to `Types/Inductive/{Name}/default.py`.

## Implemented Types

| Type | Variants | File | Status |
|------|:--------:|------|--------|
| `AlgoIdentity` | 4 | `Types/Inductive/Algo/default.py` | IMPLEMENTED |
| `OHLCVInductive` | struct (5 fields) | `Types/Inductive/OHLCV/default.py` | IMPLEMENTED |
| `ScreenerInductive` | struct (1 field) | `Types/Inductive/Screener/default.py` | IMPLEMENTED |
| `TickerInfoInductive` | struct (6 fields) | `Types/Inductive/TickerInfo/default.py` | IMPLEMENTED |
| `ScreenerQuoteInductive` | struct (1 field) | `Types/Inductive/ScreenerQuote/default.py` | IMPLEMENTED |
| `AlarmSeverity` | 3 | `Types/Inductive/AlarmSeverity/default.py` | IMPLEMENTED |
| `MetricKind` | 2 | `Types/Inductive/MetricKind/default.py` | IMPLEMENTED |

### Enum ADTs (pure sum types)

```lean
inductive AlgoIdentity where
  | ppo | sac | dqn | a2c
  deriving Repr, BEq, Inhabited

inductive AlarmSeverity where
  | info | warn | critical
  deriving Repr, BEq, Inhabited

inductive MetricKind where
  | counter | gauge
  deriving Repr, BEq, Inhabited
```

### Structural Validators (product types with IO-boundary validation)

```lean
-- OHLCV: structural validation for external market data
-- from_dataframe is the IO-boundary constructor (partial function, may fail)
structure OHLCVInductive where
  open   : Array Float    -- min_length=1, max_length=10_000_000
  high   : Array Float
  low    : Array Float
  close  : Array Float
  volume : Array Float
  deriving Repr, Lean.ToJson, Lean.FromJson

-- TickerInfo: structural validation for yfinance Ticker.info
structure TickerInfoInductive where
  symbol             : String    -- [A-Z0-9\-./=]{1,16}
  averageVolume      : Float     -- ge=-1.0, le=??? (UNBOUNDED — needs le)
  regularMarketPrice : Float     -- ge=-1.0, le=??? (UNBOUNDED — needs le)
  dayHigh            : Float     -- ge=-1.0, le=??? (UNBOUNDED — needs le)
  dayLow             : Float     -- ge=-1.0, le=??? (UNBOUNDED — needs le)
  marketCap          : Float     -- ge=-1.0, le=??? (UNBOUNDED — needs le)
  deriving Repr, Lean.ToJson, Lean.FromJson

-- ScreenerQuote: single quote from screener response
structure ScreenerQuoteInductive where
  symbol : String    -- [A-Za-z0-9\-./=]{1,20}
  deriving Repr, Lean.ToJson, Lean.FromJson

-- Screener: wrapper for screener API response
structure ScreenerInductive where
  quotes : Array ScreenerQuoteInductive    -- max_length=1000
  deriving Repr, Lean.ToJson, Lean.FromJson
```

**Refactor items:**
- [ ] Add `le` upper bounds to `TickerInfoInductive` float fields (currently unbounded)

## Inline Enums to Extract (10 types, currently violating Invariant 18)

These are `str, Enum` or `Literal` types **currently defined inline** in other strata that must be extracted to `Types/Inductive/`:

| Enum | Variants | Currently In | Extract To |
|------|:--------:|-------------|-----------|
| `AssetType` | 3: stock, crypto, forex | `Types/Identity/Asset/default.py` | `Types/Inductive/AssetType/default.py` |
| `HolidayCalendar` | 3: none, us_market, bank | `Types/Identity/Asset/default.py` | `Types/Inductive/HolidayCalendar/default.py` |
| `BrokerMode` | 3: sim, paper, live | `Types/Dependent/Env/default.py` | `Types/Inductive/BrokerMode/default.py` |
| `ObjectiveMetric` | 2: win_rate_pct, avg_return_pct | `Types/Dependent/Optimize/default.py` | `Types/Inductive/ObjectiveMetric/default.py` |
| `WaveletName` | 5: db4, db6, db8, sym4, sym6 | `Types/Hom/Feature/default.py` | `Types/Inductive/WaveletName/default.py` |
| `ThresholdMode` | 2: soft, hard | `Types/Hom/Feature/default.py` | `Types/Inductive/ThresholdMode/default.py` |
| `Severity` | 3: warn, error, fatal | `Types/Monad/Error/default.py` | `Types/Inductive/Severity/default.py` |
| `PhaseId` | 8: discovery..optimize | `Types/Monad/Error/default.py` | `Types/Inductive/PhaseId/default.py` |
| `ServeStatus` | 4: running..failed | `Types/Product/Serve/Output/default.py` | `Types/Inductive/ServeStatus/default.py` |
| `MainStatus` | 3: success, partial, failed | `Types/Product/Main/Output/default.py` | `Types/Inductive/MainStatus/default.py` |

```lean
-- All 10 to be extracted:

inductive AssetType where | stock | crypto | forex
inductive HolidayCalendar where | none | usMarket | bank
inductive BrokerMode where | sim | paper | live
inductive ObjectiveMetric where | winRatePct | avgReturnPct
inductive WaveletName where | db4 | db6 | db8 | sym4 | sym6
inductive ThresholdMode where | soft | hard
inductive Severity where | warn | error | fatal
inductive PhaseId where | discovery | ingest | feature | train | eval | serve | pipeline | optimize
inductive ServeStatus where | running | completed | stopped | failed
inductive MainStatus where | success | partial | failed
```

**New type to create:**

| Enum | Variants | Rationale |
|------|:--------:|----------|
| `IntervalInductive` | 6: m1, m5, m15, m30, h1, d1 | Replaces bare `int` on `AssetIdentity.interval_min`. Currently `interval_min=7` passes validation but crashes at IO boundary (`INTERVAL_MAP` has no entry). |

```lean
inductive IntervalInductive where
  | m1 | m5 | m15 | m30 | h1 | d1
  deriving Repr, BEq, Inhabited
```

**Post-extraction total: 18 Inductive types** (7 existing + 10 extracted + 1 new).

## Domain Terms Projecting to Stratum 2

| Term | Area | Definition | Type Mapping | Other Strata |
|------|------|-----------|--------------|-------------|
| Algorithm | Agent/Model | RL algorithm family | `AlgoIdentity` (PPO/SAC/DQN/A2C) | 4 (TrainHom.algo), 7 (IOTrainPhase) |
| OHLCV Bar | Market Data | Candlestick price record | `OHLCVInductive` | 7 (yfinance download) |
| Bar Resolution | Market Data | Temporal granularity | `IntervalInductive` (PLANNED) | 1 (AssetIdentity.interval_min) |
| Screener | Market Data | Universe discovery query | `ScreenerInductive` | 4 (DiscoveryHom.screener), 7 (IODiscoveryPhase) |
| Ticker Info | Market Data | Per-ticker metadata | `TickerInfoInductive` | 7 (IODiscoveryPhase) |
| Alarm Severity | Observability | Alert priority level | `AlarmSeverity` (info/warn/critical) | 6 (AlarmMonad.severity) |
| Metric Kind | Observability | Counter vs gauge | `MetricKind` (counter/gauge) | 6 (MetricMonad.kind) |
| Asset Type | Market Data | Security classification | `AssetType` (PLANNED) | 1 (AssetIdentity.asset_type) |
| Holiday Calendar | Market Data | Exchange holiday schedule | `HolidayCalendar` (PLANNED) | 1 (AssetIdentity.holidays) |
| Broker Mode | Execution | Sim/paper/live toggle | `BrokerMode` (PLANNED) | 3 (EnvDependent.broker_mode) |
| Order Type | Execution | Market/limit/stop/etc. | NOT IMPLEMENTED | Future: 3, 4, 5, 6, 7 |
| Order Status | Execution | Lifecycle state of an order | NOT IMPLEMENTED | Future: 5, 6, 7 |
| Time-in-Force | Execution | Order duration policy | NOT IMPLEMENTED | Future: 4, 7 |
| Regime Label | Regime Detection | Market state classification | NOT IMPLEMENTED | Future: 3, 4, 5, 7 |
| Serve Status | Infrastructure | Session outcome | `ServeStatus` (PLANNED extraction) | 5 (ServeProductOutput.status) |
| Main Status | Infrastructure | Pipeline outcome | `MainStatus` (PLANNED extraction) | 5 (MainProductOutput.status) |
| Severity | Observability | Error severity level | `Severity` (PLANNED extraction) | 6 (ErrorMonad.severity) |
| Phase ID | Infrastructure | Pipeline phase identifier | `PhaseId` (PLANNED extraction) | 6 (ErrorMonad.phase) |
| Wavelet Family | Feature Eng. | Signal decomposition basis | `WaveletName` (PLANNED extraction) | 4 (FeatureHom.wavelet) |
| Threshold Mode | Feature Eng. | Denoising strategy | `ThresholdMode` (PLANNED extraction) | 4 (FeatureHom.threshold_mode) |
| Objective Metric | Optimization | What Optuna maximizes | `ObjectiveMetric` (PLANNED extraction) | 3 (OptimizeDependent.objective_metric) |
| Slippage Model | Microstructure | Market impact type | NOT IMPLEMENTED | Future: 3, 4, 5, 6, 7 |
| Position Side | Position Mgmt | Long/short/flat | NOT IMPLEMENTED (implicit in `EnvDependent.positions`) | Future: 1, 5, 7 |
| Data Vendor | Market Data | Upstream data provider | NOT IMPLEMENTED | Future: 1, 3, 7 |

## Validation Checklist (ana-main)

- [ ] Every `Literal["a","b"]` in the codebase has been extracted to `Types/Inductive/`
- [ ] Every `str, Enum` class is in `Types/Inductive/`, not inline in another stratum
- [ ] All structural validators have `from_*` classmethods that are total over valid inputs
- [ ] `TickerInfoInductive` float fields have `le` upper bounds
- [ ] All Inductive types have `__init__.py` in their directory
- [ ] JSON roundtrip: every enum value serializes to a string and deserializes back exhaustively
