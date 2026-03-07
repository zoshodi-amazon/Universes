-- CoTypes/CoDependent/CoMachineConfig/Default.lean
-- Cofibration — observation of MachineConfig.

import Lean.Data.Json

/-- Observation of MachineConfig — lifting back to MachineArch + MachineFormat fibers. -/
structure CoMachineConfig where
  name : String
  hostnameResolvable : Bool := false
  archValid : Bool := false
  formatValid : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
