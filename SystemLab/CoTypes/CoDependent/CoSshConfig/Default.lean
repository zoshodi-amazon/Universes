-- CoTypes/CoDependent/CoSshConfig/Default.lean
-- Cofibration — observation of SshConfig.

import Lean.Data.Json

/-- Observation of SshConfig. -/
structure CoSshConfig where
  enableObserved : Bool := false
  compressionObserved : Bool := false
  serverAliveIntervalObserved : Option Nat := none
  forwardAgentObserved : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
