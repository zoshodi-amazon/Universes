-- CoTypes/CoDependent/CoBootConfig/Default.lean
-- Cofibration — observation of BootConfig.

import Lean.Data.Json

/-- Observation of BootConfig — lifting back to the BootLoader fiber. -/
structure CoBootConfig where
  enableObserved : Bool := false
  loaderValid : Bool := false
  efiObserved : Bool := false
  kernelPresent : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
