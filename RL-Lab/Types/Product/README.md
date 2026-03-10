# Stratum 5 — Product (Gas, E(3))

## Lean 4 Template

```lean
-- Stratum 5: Product (Gas, E(3))
-- Lean keyword: structure (A × B)
-- Space group: Euclidean — expanding, observable. Every computable result has
--   a typed field. No information escapes into untyped channels.
-- Split into Output (codomain of the phase morphism) and Meta (observability).

import Lean.Data.Json
import Types.Monad.Default       -- EffectMonad, ErrorMonad, etc.
import Types.Inductive.Default   -- SolverInductive, etc.

structure {Phase}ProductOutput where
  sessionId : String              -- [a-f0-9]{8}
  {domain-specific output fields}
  meta  : {Phase}ProductMeta
  deriving Repr, Lean.ToJson, Lean.FromJson

structure {Phase}ProductMeta where
  obs : EffectMonad := {}
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
5. Every Meta embeds `EffectMonad` for uniform error/measure/signal aggregation
6. Output x Meta = full Product for the phase (the 1-1-1 invariant)

**Python realization:** `pydantic.BaseModel`. Output classes have required fields (no defaults for domain data). Meta classes embed `EffectMonad` initialized with the phase's `PhaseId`.

## Implemented Types (14 = 7 Output + 7 Meta)

| Phase | Output | Output Fields | Meta | Meta Fields | Status |
|-------|--------|:------------:|------|:-----------:|--------|
| Discovery | `DiscoveryProductOutput` | 5 | `DiscoveryProductMeta` | 6 | IMPLEMENTED |
| Ingest | `IngestProductOutput` | 5 | `IngestProductMeta` | 6 | IMPLEMENTED |
| Transform | `TransformProductOutput` | 5 | `TransformProductMeta` | 5 | IMPLEMENTED |
| Solve | `SolveProductOutput` | 5 | `SolveProductMeta` | 6 | IMPLEMENTED |
| Eval | `EvalProductOutput` | 6 | `EvalProductMeta` | 6 | IMPLEMENTED |
| Project | `ProjectProductOutput` | 7 | `ProjectProductMeta` | 6 | PARTIAL |
| Compose | `ComposeProductOutput` | 7 | `ComposeProductMeta` | 5 | IMPLEMENTED |

### Key Lean Signatures

```lean
structure SolveProductOutput where
  sessionId      : String           -- [a-f0-9]{8}
  solver         : SolverInductive
  budget         : Nat              -- bounded [1, 100M]
  finalReward    : Float            -- bounded [-1e6, 1e6]
  meta           : SolveProductMeta
  deriving Repr, Lean.ToJson, Lean.FromJson

structure SolveProductMeta where
  obs              : EffectMonad := {}
  episodesCompleted: Nat    := 0        -- bounded [0, 1M]
  meanEpisodeReward: Float  := 0.0      -- bounded [-1e9, 1e9]
  stdEpisodeReward : Float  := 0.0      -- bounded [0, 1e9]
  earlyStopped     : Bool   := false
  gpuUsed          : Bool   := false
  deriving Repr, Lean.ToJson, Lean.FromJson

structure ProjectProductOutput where
  sessionId         : String          -- [a-f0-9]{8}
  ioTicker          : String          -- [A-Z0-9\-./=]{1,16}
  nBarsServed       : Nat             -- bounded [0, 10000]
  portfolioReturnPct: Float           -- bounded [-100, 1000]
  positionTaken     : Float           -- bounded [-10, 10]
  status            : ProjectStatus   -- EXTRACT to Inductive/
  meta              : ProjectProductMeta
  deriving Repr, Lean.ToJson, Lean.FromJson

structure ComposeProductOutput where
  sessionId  : String                  -- [a-f0-9]{8}
  nWindows   : Nat                     -- bounded [0, 10000]
  winRatePct : Float                   -- bounded [0, 100]
  durationS  : Float                   -- bounded [0, 86400]
  status     : ComposeStatus           -- EXTRACT to Inductive/
  results    : Array EvalProductOutput -- bounded max 10000
  meta       : ComposeProductMeta
  deriving Repr, Lean.ToJson, Lean.FromJson
```

**Refactor items:**
- [ ] Extract `ProjectStatus` from `ProjectProductOutput` to `Types/Inductive/ProjectStatus/`
- [ ] Extract `ComposeStatus` from `ComposeProductOutput` to `Types/Inductive/ComposeStatus/`
- [ ] Add `learning_rate : Float` to `SolveProductOutput` (Optuna traceability)
- [ ] Add `max_drawdown_pct : Float` to `ProjectProductMeta` (circuit breaker observation)
- [ ] Add `data_age_days : Float` and `artifact_age_min : Float` to `ProjectProductMeta` (staleness observation)

## Domain Terms Projecting to Stratum 5

| Term | Area | Definition | Type Mapping | Other Strata |
|------|------|-----------|--------------|-------------|
| Qualifying Indices | Market Data | Indices passing all filters | `DiscoveryProductOutput.qualifying_indices` | 1 (IndexIdentity per index) |
| Final Reward | Agent/Model | Last solving reward | `SolveProductOutput.final_reward` | 7 (SB3 solving) |
| Win Rate | Evaluation | % windows meeting threshold | `ComposeProductOutput.win_rate_pct` | 7 (IOComposePhase) |
| Portfolio Return | Evaluation | Cumulative session return | `ProjectProductOutput.portfolio_return_pct` | 7 (IOProjectPhase) |
| Maximum Drawdown | Evaluation | Peak-to-trough decline | `EvalProductMeta.max_drawdown_pct` | 3 (ConstraintDependent limit) |
| Equity Curve | Evaluation | Time series of portfolio value | `EvalProductOutput.results` (via ComposeProductOutput) | 7 (IOEvalPhase) |
| Orders Filled | Execution | Confirmed fill count | `ProjectProductMeta.orders_filled` | 7 (IOProjectPhase execution) |
| Execution Failures | Observability | Failed API call count | `ProjectProductMeta.execution_failures` | 6 (ErrorMonad) |
| Episodes Completed | Agent/Model | Solving episode count | `SolveProductMeta.episodes_completed` | 7 (SB3 solving) |

## Validation Checklist (ana-compose)

- [ ] Every computed value in each IO executor has a corresponding typed field
- [ ] No `print()` or `logger.info()` of computed values without a typed field capturing them
- [ ] All Output fields have bounds
- [ ] Every Meta embeds `EffectMonad` initialized with correct `PhaseId`
- [ ] `default.json` roundtrip closure
- [ ] <=7 fields per type
- [ ] Every field has `description=...`
- [ ] No inline enums (ProjectStatus, ComposeStatus extracted to Stratum 2)
