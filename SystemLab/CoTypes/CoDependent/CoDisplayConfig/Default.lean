-- CoTypes/CoDependent/CoDisplayConfig/Default.lean
-- Cofibration — observation of DisplayConfig.

import Lean.Data.Json

/-- Observation of DisplayConfig — lifting back to DisplayBackend + DisplayGreeter fibers. -/
structure CoDisplayConfig where
  enableObserved : Bool := false
  backendValid : Bool := false
  greeterValid : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
