-- CoTypes/Comonad/ObservationEvent/Default.lean
-- Trace comonad — a single observation event.

import Lean.Data.Json

/-- A single observation event in the trace. -/
structure ObservationEvent where
  phase : String
  timestamp : String := ""
  success : Bool := false
  message : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
