-- Types/Monad/ValidationResult/Default.lean
-- [Plasma] Validation result — typed effect for JSON schema validation.

import Lean.Data.Json

/-- Validation result — typed effect for JSON schema validation. -/
structure ValidationResult where
  phase : String
  valid : Bool
  errorMessage : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
