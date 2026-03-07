-- CoTypes/CoDependent/CoGitConfig/Default.lean
-- Cofibration — observation of GitConfig.

import Lean.Data.Json

/-- Observation of GitConfig. -/
structure CoGitConfig where
  enableObserved : Bool := false
  userNameSet : Bool := false
  userEmailSet : Bool := false
  defaultBranchValid : Bool := false
  deltaInstalled : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
