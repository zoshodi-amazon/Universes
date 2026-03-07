-- CoTypes/Comonad/CoValidationResult/Default.lean
-- Trace comonad — validation observation.

import Lean.Data.Json

/-- Validation observation — what we saw about a validation after the fact.
    Dual of ValidationResult (the effect of validating). -/
structure CoValidationResult where
  phase : String
  schemaConformant : Bool := false
  runtimeConformant : Bool := false
  pathsClosed : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
