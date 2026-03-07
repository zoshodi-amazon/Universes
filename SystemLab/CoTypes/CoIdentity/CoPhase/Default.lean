-- CoTypes/CoIdentity/CoPhase/Default.lean
-- Coalgebraic dual of Identity — observation witness for a phase.

import Lean.Data.Json

/-- Observation witness for a phase — did it execute? Are outputs present? -/
structure CoPhase where
  name : String
  inputsResolved : Bool := false
  outputsPresent : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
