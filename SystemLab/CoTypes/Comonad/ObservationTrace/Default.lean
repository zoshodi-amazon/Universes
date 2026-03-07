-- CoTypes/Comonad/ObservationTrace/Default.lean
-- Trace comonad — the comonad itself.

import Lean.Data.Json
import CoTypes.Comonad.ObservationEvent.Default

/-- Observation trace — the comonad.
    `current` is `extract` (the focused observation).
    `history` is the context for `extend` (map over past observations). -/
structure ObservationTrace where
  current : ObservationEvent
  history : List ObservationEvent := []
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Extract the current observation from a trace (comonad extract). -/
def ObservationTrace.extract (w : ObservationTrace) : ObservationEvent :=
  w.current

/-- Push a new observation onto the trace, shifting current to history. -/
def ObservationTrace.push (w : ObservationTrace) (event : ObservationEvent) : ObservationTrace :=
  { current := event, history := w.current :: w.history }
