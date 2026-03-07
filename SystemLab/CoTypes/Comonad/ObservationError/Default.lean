-- CoTypes/Comonad/ObservationError/Default.lean
-- Trace comonad — observation error co-effect.

import Lean.Data.Json

/-- Observation error — the co-effect of a failed observation.
    Dual of PhaseError (the effect of a failed production). -/
structure ObservationError where
  phase : String
  message : String
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
