-- CoTypes/CoProduct/CoIdentityOutput/Default.lean
-- Coproduct — observation output for Identity phase.

import Lean.Data.Json

/-- Observation output for Identity phase. -/
structure CoIdentityOutput where
  nixEnabled : Bool := false
  gcActive : Bool := false
  substituters : List String := []
  sopsKeyPresent : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
