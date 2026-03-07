-- Types/Monad/PhaseError/Default.lean
-- [Plasma] Phase execution error — typed effect for pipeline failures.

import Lean.Data.Json

/-- Phase execution error — typed effect for pipeline failures. -/
structure PhaseError where
  phase : String
  message : String
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
