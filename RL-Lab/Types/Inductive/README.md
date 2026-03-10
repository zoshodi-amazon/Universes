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
| `SolverInductive` | 4 | `Types/Inductive/Solver/default.py` | IMPLEMENTED |
| `FrameInductive` | struct (5 fields) | `Types/Inductive/Frame/default.py` | IMPLEMENTED |
| `CatalogInductive` | struct (1 field) | `Types/Inductive/Catalog/default.py` | IMPLEMENTED |
| `IndexMetaInductive` | struct (6 fields) | `Types/Inductive/IndexMeta/default.py` | IMPLEMENTED |
| `CatalogEntryInductive` | struct (1 field) | `Types/Inductive/CatalogEntry/default.py` | IMPLEMENTED |
| `SeverityInductive` | 3 | `Types/Inductive/SeverityInductive/default.py` | IMPLEMENTED |
| `MeasureInductive` | 2 | `Types/Inductive/MeasureInductive/default.py` | IMPLEMENTED |

### Enum ADTs (pure sum types)

```lean
inductive SolverInductive where
  | ppo | sac | dqn | a2c
  deriving Repr, BEq, Inhabited

inductive SeverityInductive where
  | info | warn | critical
  deriving Repr, BEq, Inhabited

inductive MeasureInductive where
  | counter | gauge
  deriving Repr, BEq, Inhabited
```

### Structural Validators (product types with IO-boundary validation)

```lean
-- Frame: structural validation for external market data
-- from_dataframe is the IO-boundary constructor (partial function, may fail)
structure FrameInductive where
  open   : Array Float    -- min_length=1, max_length=10_000_000
  high   : Array Float
  low    : Array Float
  close  : Array Float
  volume : Array Float
  deriving Repr, Lean.ToJson, Lean.FromJson

-- IndexMeta: structural validation for yfinance Ticker.info
structure IndexMetaInductive where
  symbol             : String    -- [A-Z0-9\-./=]{1,16}
  averageVolume      : Float     -- ge=-1.0, le=??? (UNBOUNDED — needs le)
  regularMarketPrice : Float     -- ge=-1.0, le=??? (UNBOUNDED — needs le)
  dayHigh            : Float     -- ge=-1.0, le=??? (UNBOUNDED — needs le)
  dayLow             : Float     -- ge=-1.0, le=??? (UNBOUNDED — needs le)
  marketCap          : Float     -- ge=-1.0, le=??? (UNBOUNDED — needs le)
  deriving Repr, Lean.ToJson, Lean.FromJson

-- CatalogEntry: single quote from catalog response
structure CatalogEntryInductive where
  symbol : String    -- [A-Za-z0-9\-./=]{1,20}
  deriving Repr, Lean.ToJson, Lean.FromJson

-- Catalog: wrapper for catalog API response
structure CatalogInductive where
  quotes : Array CatalogEntryInductive    -- max_length=1000
  deriving Repr, Lean.ToJson, Lean.FromJson
```

**Refactor items:**
- [ ] Add `le` upper bounds to `IndexMetaInductive` float fields (currently unbounded)

## Inline Enums to Extract (10 types, currently violating Invariant 18)

These are `str, Enum` or `Literal` types **currently defined inline** in other strata that must be extracted to `Types/Inductive/`:

| Enum | Variants | Currently In | Extract To |
|------|:--------:|-------------|-----------|
| `IndexClass` | 3: stock, crypto, forex | `Types/Identity/Index/default.py` | `Types/Inductive/IndexClass/default.py` |
| `TemporalMask` | 3: none, us_market, bank | `Types/Identity/Index/default.py` | `Types/Inductive/TemporalMask/default.py` |
| `ExecutionMode` | 3: sim, paper, live | `Types/Dependent/Execution/default.py` | `Types/Inductive/ExecutionMode/default.py` |
| `ObjectiveInductive` | 2: win_rate_pct, avg_return_pct | `Types/Dependent/Search/default.py` | `Types/Inductive/ObjectiveInductive/default.py` |
| `BasisInductive` | 5: db4, db6, db8, sym4, sym6 | `Types/Hom/Transform/default.py` | `Types/Inductive/BasisInductive/default.py` |
| `ThresholdMode` | 2: soft, hard | `Types/Hom/Transform/default.py` | `Types/Inductive/ThresholdMode/default.py` |
| `Severity` | 3: warn, error, fatal | `Types/Monad/Error/default.py` | `Types/Inductive/Severity/default.py` |
| `PhaseId` | 8: discovery..search | `Types/Monad/Error/default.py` | `Types/Inductive/PhaseId/default.py` |
| `ProjectStatus` | 4: running..failed | `Types/Product/Project/Output/default.py` | `Types/Inductive/ProjectStatus/default.py` |
| `ComposeStatus` | 3: success, partial, failed | `Types/Product/Compose/Output/default.py` | `Types/Inductive/ComposeStatus/default.py` |

```lean
-- All 10 to be extracted:

inductive IndexClass where | stock | crypto | forex
inductive TemporalMask where | none | usMarket | bank
inductive ExecutionMode where | sim | paper | live
inductive ObjectiveInductive where | winRatePct | avgReturnPct
inductive BasisInductive where | db4 | db6 | db8 | sym4 | sym6
inductive ThresholdMode where | soft | hard
inductive Severity where | warn | error | fatal
inductive PhaseId where | discovery | ingest | transform | solve | eval | project | compose | search
inductive ProjectStatus where | running | completed | stopped | failed
inductive ComposeStatus where | success | partial | failed
```

**New type to create:**

| Enum | Variants | Rationale |
|------|:--------:|----------|
| `IntervalInductive` | 6: m1, m5, m15, m30, h1, d1 | Replaces bare `int` on `IndexIdentity.interval_min`. Currently `interval_min=7` passes validation but crashes at IO boundary (`INTERVAL_MAP` has no entry). |

```lean
inductive IntervalInductive where
  | m1 | m5 | m15 | m30 | h1 | d1
  deriving Repr, BEq, Inhabited
```

**Post-extraction total: 18 Inductive types** (7 existing + 10 extracted + 1 new).

## Domain Terms Projecting to Stratum 2

| Term | Area | Definition | Type Mapping | Other Strata |
|------|------|-----------|--------------|-------------|
| Solver | Agent/Model | RL algorithm family | `SolverInductive` (PPO/SAC/DQN/A2C) | 4 (SolveHom.solver), 7 (IOSolvePhase) |
| OHLCV Bar | Market Data | Candlestick price record | `FrameInductive` | 7 (yfinance download) |
| Bar Resolution | Market Data | Temporal granularity | `IntervalInductive` (PLANNED) | 1 (IndexIdentity.interval_min) |
| Catalog | Market Data | Universe discovery query | `CatalogInductive` | 4 (DiscoveryHom.catalog_source), 7 (IODiscoveryPhase) |
| Index Meta | Market Data | Per-ticker metadata | `IndexMetaInductive` | 7 (IODiscoveryPhase) |
| Alarm Severity | Observability | Alert priority level | `SeverityInductive` (info/warn/critical) | 6 (SignalMonad.severity) |
| Measure Kind | Observability | Counter vs gauge | `MeasureInductive` (counter/gauge) | 6 (MeasureMonad.kind) |
| Index Class | Market Data | Security classification | `IndexClass` (PLANNED) | 1 (IndexIdentity.index_class) |
| Temporal Mask | Market Data | Exchange holiday schedule | `TemporalMask` (PLANNED) | 1 (IndexIdentity.holidays) |
| Execution Mode | Execution | Sim/paper/live toggle | `ExecutionMode` (PLANNED) | 3 (ExecutionDependent.execution_mode) |
| Order Type | Execution | Market/limit/stop/etc. | NOT IMPLEMENTED | Future: 3, 4, 5, 6, 7 |
| Order Status | Execution | Lifecycle state of an order | NOT IMPLEMENTED | Future: 5, 6, 7 |
| Time-in-Force | Execution | Order duration policy | NOT IMPLEMENTED | Future: 4, 7 |
| Regime Label | Regime Detection | Market state classification | NOT IMPLEMENTED | Future: 3, 4, 5, 7 |
| Project Status | Infrastructure | Session outcome | `ProjectStatus` (PLANNED extraction) | 5 (ProjectProductOutput.status) |
| Compose Status | Infrastructure | Pipeline outcome | `ComposeStatus` (PLANNED extraction) | 5 (ComposeProductOutput.status) |
| Severity | Observability | Error severity level | `Severity` (PLANNED extraction) | 6 (ErrorMonad.severity) |
| Phase ID | Infrastructure | Pipeline phase identifier | `PhaseId` (PLANNED extraction) | 6 (ErrorMonad.phase) |
| Basis Family | Transform Eng. | Signal decomposition basis | `BasisInductive` (PLANNED extraction) | 4 (TransformHom.basis) |
| Threshold Mode | Transform Eng. | Denoising strategy | `ThresholdMode` (PLANNED extraction) | 4 (TransformHom.threshold_mode) |
| Objective Inductive | Optimization | What Optuna maximizes | `ObjectiveInductive` (PLANNED extraction) | 3 (SearchDependent.objective_metric) |
| Slippage Model | Microstructure | Market impact type | NOT IMPLEMENTED | Future: 3, 4, 5, 6, 7 |
| Position Side | Position Mgmt | Long/short/flat | NOT IMPLEMENTED (implicit in `ExecutionDependent.positions`) | Future: 1, 5, 7 |
| Data Vendor | Market Data | Upstream data provider | NOT IMPLEMENTED | Future: 1, 3, 7 |

## Validation Checklist (ana-main)

- [ ] Every `Literal["a","b"]` in the codebase has been extracted to `Types/Inductive/`
- [ ] Every `str, Enum` class is in `Types/Inductive/`, not inline in another stratum
- [ ] All structural validators have `from_*` classmethods that are total over valid inputs
- [ ] `IndexMetaInductive` float fields have `le` upper bounds
- [ ] All Inductive types have `__init__.py` in their directory
- [ ] JSON roundtrip: every enum value serializes to a string and deserializes back exhaustively
