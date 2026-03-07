-- Types/Dependent/MachineUser/Default.lean
-- [Liquid Crystal] Machine user account.

import Lean.Data.Json

/-- Machine user account. -/
structure MachineUser where
  name : String
  groups : List String := ["wheel"]
  initialPassword : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
