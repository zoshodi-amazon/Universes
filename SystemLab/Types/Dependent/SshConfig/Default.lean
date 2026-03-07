-- Types/Dependent/SshConfig/Default.lean
-- [Liquid Crystal] SSH configuration.

import Lean.Data.Json

/-- SSH configuration. -/
structure SshConfig where
  enable : Bool := true
  compression : Bool := true
  serverAliveInterval : Nat := 60
  serverAliveCountMax : Nat := 3
  forwardAgent : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
