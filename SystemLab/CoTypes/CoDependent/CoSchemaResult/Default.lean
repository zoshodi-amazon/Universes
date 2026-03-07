-- CoTypes/CoDependent/CoSchemaResult/Default.lean
-- Cofibration — schema conformance result.

import Lean.Data.Json

/-- Schema conformance result — does an observation inhabit its expected fiber? -/
structure CoSchemaResult where
  structureName : String
  conformant : Bool := false
  missingFields : List String := []
  extraFields : List String := []
  deriving Repr, Lean.ToJson, Lean.FromJson
