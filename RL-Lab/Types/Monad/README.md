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
  error  : ErrorMonad  → M Unit
  metric : MetricMonad → M Unit
  alarm  : AlarmMonad  → M Unit

/-- Free representation: effects accumulate as lists. -/
structure ObservabilityMonad where
  errors     : Array ErrorMonad  := #[]    -- max 1000
  metrics    : Array MetricMonad := #[]    -- max 1000
  alarms     : Array AlarmMonad  := #[]    -- max 1000
  phase      : PhaseId           := .discovery
  durationS  : Float             := 0.0    -- bounded [0, 86400]
  startedAt  : String            := ""     -- ISO timestamp
  completedAt: String            := ""     -- ISO timestamp
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Closure: every IO executor returns a typed Product. No raise bypasses the type. -/
```

## Space Group & Closure

**Symmetry:** Gauge group. Effects are the "gauge field" of the system — they compose freely, accumulate during execution, and discharge at the phase boundary when the Product is returned. The Monad stratum is the free algebra over three generators: error, metric, alarm.

**Closure conditions:**
1. Every possible system effect is representable as an `ErrorMonad`, `MetricMonad`, or `AlarmMonad`
2. `ObservabilityMonad` composes all three as bounded lists (the free algebra)
3. Every IO executor returns a typed Product containing `ObservabilityMonad` in its Meta
4. No `raise` statement bypasses the typed return path — all exceptions are caught and recorded as `ErrorMonad` entries
5. No computed metric escapes into stdout-only logging — it must also be captured in `MetricMonad`
6. The Monad stratum is terminal in the import DAG — it may reference all lower layers

**Python realization:** `pydantic.BaseModel` for each effect type. `ObservabilityMonad` aggregates them. IO executors wrap their `run()` in try/except and always return a typed Product.

## Implemented Types

| Type | Fields | Purpose | File | Status |
|------|:------:|---------|------|--------|
| `ErrorMonad` | 4 | Typed error with phase + severity | `Types/Monad/Error/default.py` | PARTIAL (has inline enums) |
| `MetricMonad` | 3 | Single metric observation | `Types/Monad/Metric/default.py` | IMPLEMENTED |
| `AlarmMonad` | 5 | Threshold-based alert | `Types/Monad/Alarm/default.py` | IMPLEMENTED |
| `ArtifactRow` | 6 | Single artifact DB record | `Types/Monad/Artifact/default.py` | IMPLEMENTED |
| `StoreMonad` | 5 (+methods) | Typed artifact store | `Types/Monad/Store/default.py` | IMPLEMENTED |
| `ObservabilityMonad` | 7 | Free effect algebra | `Types/Monad/Observability/default.py` | IMPLEMENTED |

### Lean Signatures

```lean
structure ErrorMonad where
  phase       : PhaseId            -- EXTRACT to Inductive/
  message     : String             -- max 1024 chars
  windowIndex : Int    := -1       -- bounded [-1, 10000]
  severity    : Severity := .warn  -- EXTRACT to Inductive/
  deriving Repr, Lean.ToJson, Lean.FromJson

structure MetricMonad where
  name  : String      -- snake_case, 1-64 chars
  value : Float       -- bounded [-1e15, 1e15]
  kind  : MetricKind  -- counter | gauge (from Inductive/)
  deriving Repr, Lean.ToJson, Lean.FromJson

structure AlarmMonad where
  name      : String          -- snake_case, 1-64 chars
  severity  : AlarmSeverity   -- from Inductive/
  message   : String          -- max 256 chars
  threshold : Float           -- bounded [-1e15, 1e15]
  actual    : Float           -- bounded [-1e15, 1e15]
  deriving Repr, Lean.ToJson, Lean.FromJson

structure ArtifactRow where
  runId        : String    -- [a-f0-9]{8}
  phase        : String    -- max 32 chars
  artifactType : String    -- max 32 chars
  blobPath     : String    -- max 512 chars
  metadataJson : String    -- max ??? (UNBOUNDED — needs max_length)
  createdAt    : String    -- ISO timestamp
  deriving Repr, Lean.ToJson, Lean.FromJson

structure StoreMonad where
  dbUrl   : String := "sqlite:///store/.rl.db"   -- max 512 chars
  blobDir : String := "store/blobs"              -- max 256 chars
  runId   : String := ""                          -- [a-f0-9]{8}
  phase   : String := ""                          -- max 32 chars
  docsDir : String := "store/docs"               -- max 256 chars
  deriving Repr, Lean.ToJson, Lean.FromJson
  -- effectful methods: put, get, latest, all_runs (IO actions)

structure ObservabilityMonad where
  errors      : Array ErrorMonad  := #[]   -- max 1000
  metrics     : Array MetricMonad := #[]   -- max 1000
  alarms      : Array AlarmMonad  := #[]   -- max 1000
  phase       : PhaseId           := .discovery
  durationS   : Float             := 0.0   -- bounded [0, 86400]
  startedAt   : String            := ""    -- ISO timestamp
  completedAt : String            := ""    -- ISO timestamp
  deriving Repr, Lean.ToJson, Lean.FromJson
```

**Refactor items:**
- [ ] Extract `Severity` from `ErrorMonad` to `Types/Inductive/Severity/`
- [ ] Extract `PhaseId` from `ErrorMonad` to `Types/Inductive/PhaseId/`
- [ ] Add `max_length` bound to `ArtifactRow.metadata_json`
- [ ] Add `min_length=0` to `ObservabilityMonad.started_at` and `.completed_at`
- [ ] Wrap all 19 `raise` statements across IO executors in try/except returning typed Product
- [ ] Populate `MetricMonad` entries in the 5 phases that currently skip it

## Domain Terms Projecting to Stratum 6

| Term | Area | Definition | Type Mapping | Other Strata |
|------|------|-----------|--------------|-------------|
| Structured Logging | Observability | JSON-formatted typed log records | `ErrorMonad`, `ObservabilityMonad` | 5 (ProductMeta.obs), 7 (IO) |
| Counter Metric | Observability | Monotonically increasing metric | `MetricMonad` (kind=counter) | 2 (MetricKind.counter) |
| Gauge Metric | Observability | Variable-value metric | `MetricMonad` (kind=gauge) | 2 (MetricKind.gauge) |
| Alert | Observability | Threshold-breach notification | `AlarmMonad` | 2 (AlarmSeverity), 3 (AlarmDependent) |
| Audit Trail | Observability | Immutable action record | `ArtifactRow` + JSONL audit log | 7 (IOServePhase) |
| Artifact | Persistence | Any serialized output | `ArtifactRow` in `StoreMonad` | 7 (all IO executors) |
| Model Checkpoint | Persistence | Saved model weights | `StoreMonad.put("model", ...)` | 7 (IOTrainPhase) |
| Run ID | Persistence | Unique execution identifier | `StoreMonad.run_id` | 1 (RunIdentity.run_id) |
| Error Severity | Observability | Warn/error/fatal classification | `ErrorMonad.severity` | 2 (Severity ADT) |
| Dead Letter Queue | Observability | Failed event storage | NOT IMPLEMENTED | Future: `StoreMonad` extension |
| Performance Attribution | Observability | Per-position return decomposition | NOT IMPLEMENTED | Future: `MetricMonad` entries |
| Drift Detection | Observability | Feature distribution shift | NOT IMPLEMENTED | Future: `AlarmMonad` trigger |

## Validation Checklist (ana-main)

- [ ] Every IO executor's `run()` is wrapped in try/except, always returns typed Product
- [ ] No `raise` statement bypasses `ObservabilityMonad` error recording
- [ ] All 7 IO executors populate `MetricMonad` entries for their computed metrics
- [ ] `ArtifactRow.metadata_json` has `max_length` bound
- [ ] All Inductive-typed fields import from `Types/Inductive/`
- [ ] `default.json` roundtrip closure
- [ ] <=7 fields per type
- [ ] Every field has `description=...`
