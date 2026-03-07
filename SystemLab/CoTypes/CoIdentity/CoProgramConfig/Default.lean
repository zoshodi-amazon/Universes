-- CoTypes/CoIdentity/CoProgramConfig/Default.lean
-- Coalgebraic dual of Identity — observation witness for a program.

import Lean.Data.Json

/-- Observation witness for a program — is it reachable on PATH? -/
structure CoProgramConfig where
  name : String
  reachable : Bool := false
  storePathExists : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
