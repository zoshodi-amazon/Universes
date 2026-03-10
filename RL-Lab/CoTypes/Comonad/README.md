# CoStratum 6 — Comonad (Plasma Dual, Co-effects)

## Lean 4 Template

```lean
-- CoStratum 6: Comonad (Plasma dual, co-effects)
-- Lean keyword: class + structure (comonadic observation: extract + extend)
-- Duality: Monad (effects) ↔ Comonad (co-effects / observation traces)
-- Where Monad accumulates effects during execution, Comonad accumulates
--   observations during probing. extract = current, extend = history.

class Comonad (W : Type → Type) where
  extract : W α → α               -- get current observation value
  extend  : (W α → β) → W α → W β -- apply observation function across trace

/-- Free representation: observation state as structure. -/
structure {Name}Comonad where
  {observation state fields}
  deriving Repr, Lean.ToJson, Lean.FromJson
```

## Duality & Closure

**Dual of:** Stratum 6 (Monad, effect types).

Where `ErrorMonad` accumulates errors during execution (the free monad), `CoErrorComonad` summarizes what was **observed** about errors across probes (the cofree comonad). Where `EffectMonad` is the effect algebra (errors × metrics × signals), `TraceComonad` is the observation cursor that tracks the observer's position in the event stream.

**Comonad laws:**
- `extract`: get the current observation value (e.g., `TraceComonad.cursor` = current position)
- `extend`: apply an observation function to produce a new trace (e.g., advance cursor, update `events_seen`)

## Implemented Types (5)

| Type | Fields | Dual Of | File |
|------|:------:|---------|------|
| `TraceComonad` | 5 | `EffectMonad` | `CoTypes/Comonad/Trace/default.py` |
| `CoErrorComonad` | 4 | `ErrorMonad` | `CoTypes/Comonad/Error/default.py` |
| `CoMeasureComonad` | 4 | `MeasureMonad` | `CoTypes/Comonad/Measure/default.py` |
| `CoSignalComonad` | 4 | `SignalMonad` | `CoTypes/Comonad/Signal/default.py` |
| `CoStoreComonad` | 5 | `StoreMonad` | `CoTypes/Comonad/Store/default.py` |

```lean
-- CoPhaseId: observer-side phase enum (distinct from PhaseId in Types/Monad/Error/)
inductive CoPhaseId where
  | discovery | ingest | transform | solve | eval | project | compose
  deriving Repr, BEq, Inhabited

structure TraceComonad where
  observerId  : String := ""       -- unique observer instance ID
  cursor      : Nat    := 0        -- extract: current position in event stream
  eventsSeen  : Nat    := 0        -- total events processed
  connectionOk: Bool   := false    -- is the event source reachable?
  lastSeenAt  : String := ""       -- ISO timestamp of last observation
  deriving Repr, Lean.ToJson, Lean.FromJson

structure CoErrorComonad where
  errorCount    : Nat    := 0      -- total errors observed
  hasFatal      : Bool   := false  -- any fatal-severity errors?
  worstSeverity : String := ""     -- highest severity seen
  lastMessage   : String := ""     -- most recent error message
  deriving Repr, Lean.ToJson, Lean.FromJson

structure CoStoreComonad where
  dbReachable    : Bool   := false  -- can we connect to SQLite?
  artifactCount  : Nat    := 0      -- total artifact rows
  blobDirExists  : Bool   := false  -- is store/blobs/ on disk?
  latestCreated  : String := ""     -- most recent artifact timestamp
  diskUsageMb    : Float  := 0.0    -- total blob directory size
  deriving Repr, Lean.ToJson, Lean.FromJson
```

**Naming note:** `TraceComonad` uses `TraceComonad` rather than `CoTraceComonad` — it is the dual of `EffectMonad`, not `ObservabilityMonad`. Documented as cosmetic issue.

## Validation Checklist

- [ ] 1-1 correspondence: every `Types/Monad/{X}/` has a `CoTypes/Comonad/{X}/` or equivalent
- [ ] `CoPhaseId` is distinct from `PhaseId` (observer vs. production)
- [ ] All 5 Comonad types have `__init__.py` in their directories
