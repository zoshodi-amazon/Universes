-- CoTypes/CoProduct/CoServicesOutput/Default.lean
-- Coproduct — observation output for Services phase.

import Lean.Data.Json

/-- Observation output for Services phase. -/
structure CoServicesOutput where
  containerBackendRunning : Bool := false
  containerCount : Nat := 0
  deriving Repr, Lean.ToJson, Lean.FromJson
