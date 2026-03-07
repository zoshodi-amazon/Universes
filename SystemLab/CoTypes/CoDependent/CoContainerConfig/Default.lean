-- CoTypes/CoDependent/CoContainerConfig/Default.lean
-- Cofibration — observation of ContainerConfig.

import Lean.Data.Json

/-- Observation of ContainerConfig — lifting back to ContainerBackend fiber. -/
structure CoContainerConfig where
  enableObserved : Bool := false
  backendValid : Bool := false
  backendRunning : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
