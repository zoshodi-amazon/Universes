-- CoTypes/CoDependent/CoMachineUser/Default.lean
-- Cofibration — observation of MachineUser.

import Lean.Data.Json

/-- Observation of MachineUser — is the user account present? -/
structure CoMachineUser where
  name : String
  accountExists : Bool := false
  groupsPresent : List Bool := []
  deriving Repr, Lean.ToJson, Lean.FromJson
