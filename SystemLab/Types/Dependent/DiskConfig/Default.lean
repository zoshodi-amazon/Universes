-- Types/Dependent/DiskConfig/Default.lean
-- [Liquid Crystal] Disk configuration — parameterized by DiskLayout.

import Lean.Data.Json
import Types.Inductive.DiskLayout.Default

/-- Disk configuration — parameterized by DiskLayout. -/
structure DiskConfig where
  layout : DiskLayout := .none
  device : String := "/dev/sda"
  filesystem : String := "ext4"
  encryption : String := "none"
  remoteUnlock : Bool := false
  swapSize : String := "none"
  deriving Repr, Lean.ToJson, Lean.FromJson
