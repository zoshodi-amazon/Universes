-- CoTypes/CoDependent/CoDiskConfig/Default.lean
-- Cofibration — observation of DiskConfig.

import Lean.Data.Json

/-- Observation of DiskConfig — lifting back to DiskLayout fiber. -/
structure CoDiskConfig where
  layoutValid : Bool := false
  deviceExists : Bool := false
  filesystemValid : Bool := false
  encryptionActive : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
