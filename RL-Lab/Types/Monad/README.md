# Stratum 6 — Monad (Plasma, Gauge Group)

## Lean 4 Template

```lean
-- Stratum 6: Monad (Plasma, gauge group)
-- Lean keyword: class + instance (typeclass for monadic effects)
--   + structure (free representation as list accumulation)
-- Space group: gauge — effect types that compose, accumulate, and discharge
--   at the phase boundary. Every possible system effect has a typed representation.

import Lean.Data.Json
import Types.Inductive.Default

/-- The effect algebra interface. -/
class EffectAlgebra (M : Type → Type) where
  error   : ErrorMonad   → M Unit
  measure : MeasureMonad → M Unit
  signal  : SignalMonad  → M Unit

/-- Free representation: effects accumulate as lists. -/
structure EffectMonad where
  errors    : Array ErrorMonad   := #[]    -- max 1000
  measures  : Array MeasureMonad := #[]    -- max 1000
  signals   : Array SignalMonad  := #[]    -- max 1000
  phase     : PhaseId            := .discovery
  durationS : Float              := 0.0    -- bounded [0, 86400]
  startedAt : String             := ""     -- ISO timestamp
  completedAt: String            := ""     -- ISO timestamp
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Closure: every IO executor returns a typed Product via IOResult. No raise bypasses the type. -/
```

## Space Group & Closure

**Symmetry:** Gauge group. Effects are the "gauge field" of the system — they compose freely, accumulate during execution, and discharge at the phase boundary when the Product is returned. The Monad stratum is the free algebra over three generators: error, measure, signal.

**Closure conditions:**
1. Every possible system effect is representable as an `ErrorMonad`, `MeasureMonad`, or `SignalMonad`
2. `EffectMonad` composes all three as bounded lists (the free algebra)
3. Every IO executor returns a typed Product containing `EffectMonad` in its Meta via `IOResult[T, ErrorMonad]`
4. No `raise` statement bypasses the typed return path — all exceptions are captured by `@safe` / `@impure_safe` decorators from `dry-python/returns`
5. No computed measure escapes into stdout-only logging — it must also be captured in `MeasureMonad`
6. The Monad stratum is terminal in the import DAG — it may reference all lower layers

**Python realization:** `pydantic.BaseModel` for each effect type. `EffectMonad` aggregates them. IO executors use `dry-python/returns` for monadic effect handling: `IOResult[T, ErrorMonad]`, `Result[T, ErrorMonad]`, `Maybe[T]`, `@safe`/`@impure_safe`.

## Implemented Types

| Type | Fields | Purpose | File | Status |
|------|:------:|---------|------|--------|
| `ErrorMonad` | 4 | Typed error with phase + severity | `Types/Monad/Error/default.py` | PARTIAL (has inline enums) |
| `MeasureMonad` | 3 | Single measure observation | `Types/Monad/Measure/default.py` | IMPLEMENTED |
| `SignalMonad` | 5 | Threshold-based signal | `Types/Monad/Signal/default.py` | IMPLEMENTED |
| `ArtifactMonad` | 6 | Single artifact DB record | `Types/Monad/Artifact/default.py` | IMPLEMENTED |
| `StoreMonad` | 5 (+methods) | Typed artifact store | `Types/Monad/Store/default.py` | IMPLEMENTED |
| `EffectMonad` | 7 | Free effect algebra | `Types/Monad/Effect/default.py` | IMPLEMENTED |

### Lean Signatures

```lean
structure ErrorMonad where
  phase       : PhaseId            -- EXTRACT to Inductive/
  message     : String             -- max 1024 chars
  windowIndex : Int    := -1       -- bounded [-1, 10000]
  severity    : Severity := .warn  -- EXTRACT to Inductive/
  deriving Repr, Lean.ToJson, Lean.FromJson

structure MeasureMonad where
  name  : String         -- snake_case, 1-64 chars
  value : Float          -- bounded [-1e15, 1e15]
  kind  : MeasureInductive  -- counter | gauge (from Inductive/)
  deriving Repr, Lean.ToJson, Lean.FromJson

structure SignalMonad where
  name      : String             -- snake_case, 1-64 chars
  severity  : SeverityInductive  -- from Inductive/
  message   : String             -- max 256 chars
  threshold : Float              -- bounded [-1e15, 1e15]
  actual    : Float              -- bounded [-1e15, 1e15]
  deriving Repr, Lean.ToJson, Lean.FromJson

structure ArtifactMonad where
  sessionId    : String    -- [a-f0-9]{8}
  phase        : String    -- max 32 chars
  artifactType : String    -- max 32 chars
  blobPath     : String    -- max 512 chars
  metadataJson : String    -- max ??? (UNBOUNDED — needs max_length)
  createdAt    : String    -- ISO timestamp
  deriving Repr, Lean.ToJson, Lean.FromJson

structure StoreMonad where
  dbUrl     : String := "sqlite:///store/.rl.db"   -- max 512 chars
  blobDir   : String := "store/blobs"              -- max 256 chars
  sessionId : String := ""                          -- [a-f0-9]{8}
  phase     : String := ""                          -- max 32 chars
  docsDir   : String := "store/docs"               -- max 256 chars
  deriving Repr, Lean.ToJson, Lean.FromJson
  -- effectful methods: put -> IOResult, get -> Maybe[ArtifactMonad], latest, all_runs

structure EffectMonad where
  errors     : Array ErrorMonad   := #[]   -- max 1000
  measures   : Array MeasureMonad := #[]   -- max 1000
  signals    : Array SignalMonad  := #[]   -- max 1000
  phase      : PhaseId            := .discovery
  durationS  : Float              := 0.0   -- bounded [0, 86400]
  startedAt  : String             := ""    -- ISO timestamp
  completedAt: String             := ""    -- ISO timestamp
  deriving Repr, Lean.ToJson, Lean.FromJson
```

**Refactor items:**
- [ ] Extract `Severity` from `ErrorMonad` to `Types/Inductive/Severity/`
- [ ] Extract `PhaseId` from `ErrorMonad` to `Types/Inductive/PhaseId/`
- [ ] Add `max_length` bound to `ArtifactMonad.metadata_json`
- [ ] Add `min_length=0` to `EffectMonad.started_at` and `.completed_at`
- [ ] Wrap all `raise` statements via `@safe`/`@impure_safe` from `dry-python/returns`
- [ ] Populate `MeasureMonad` entries in the 5 phases that currently skip it

## Domain Terms Projecting to Stratum 6

| Term | Area | Definition | Type Mapping | Other Strata |
|------|------|-----------|--------------|-------------|
| Structured Logging | Observability | JSON-formatted typed log records | `ErrorMonad`, `EffectMonad` | 5 (ProductMeta.obs), 7 (IO) |
| Counter Measure | Observability | Monotonically increasing measure | `MeasureMonad` (kind=counter) | 2 (MeasureInductive.counter) |
| Gauge Measure | Observability | Variable-value measure | `MeasureMonad` (kind=gauge) | 2 (MeasureInductive.gauge) |
| Signal | Observability | Threshold-breach notification | `SignalMonad` | 2 (SeverityInductive), 3 (ThresholdDependent) |
| Audit Trail | Observability | Immutable action record | `ArtifactMonad` + JSONL audit log | 7 (IOProjectPhase) |
| Artifact | Persistence | Any serialized output | `ArtifactMonad` in `StoreMonad` | 7 (all IO executors) |
| Model Checkpoint | Persistence | Saved model weights | `StoreMonad.put("model", ...)` | 7 (IOSolvePhase) |
| Session ID | Persistence | Unique execution identifier | `StoreMonad.session_id` | 1 (SessionIdentity.session_id) |
| Error Severity | Observability | Warn/error/fatal classification | `ErrorMonad.severity` | 2 (Severity ADT) |

## Validation Checklist (ana-compose)

- [ ] Every IO executor's `run()` returns `IOResult[ProductOutput, ErrorMonad]` via `@impure_safe`
- [ ] No `raise` statement bypasses `EffectMonad` error recording
- [ ] All 7 IO executors populate `MeasureMonad` entries for their computed measures
- [ ] `ArtifactMonad.metadata_json` has `max_length` bound
- [ ] All Inductive-typed fields import from `Types/Inductive/`
- [ ] `default.json` roundtrip closure
- [ ] <=7 fields per type
- [ ] Every field has `description=...`
