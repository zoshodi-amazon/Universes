-- CoTypes/CoDependent/CoHomeTarget/Default.lean
-- Cofibration — observation of HomeTarget.

import Lean.Data.Json

/-- Observation of HomeTarget. -/
structure CoHomeTarget where
  enableObserved : Bool := false
  usernameMatches : Bool := false
  homeDirectoryExists : Bool := false
  stateVersionValid : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
