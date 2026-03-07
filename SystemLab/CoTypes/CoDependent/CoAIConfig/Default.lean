-- CoTypes/CoDependent/CoAIConfig/Default.lean
-- Cofibration — observation of AIConfig.

import Lean.Data.Json

/-- Observation of AIConfig — lifting back to AIProvider fiber. -/
structure CoAIConfig where
  enableObserved : Bool := false
  providerValid : Bool := false
  regionSet : Bool := false
  profileSet : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
