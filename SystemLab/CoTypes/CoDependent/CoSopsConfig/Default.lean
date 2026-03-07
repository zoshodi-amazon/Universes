-- CoTypes/CoDependent/CoSopsConfig/Default.lean
-- Cofibration — observation of SopsConfig.

import Lean.Data.Json

/-- Observation of SopsConfig — is the age key file reachable? -/
structure CoSopsConfig where
  enableObserved : Bool := false
  ageKeyFileExists : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
