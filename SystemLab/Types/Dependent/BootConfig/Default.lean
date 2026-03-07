-- Types/Dependent/BootConfig/Default.lean
-- [Liquid Crystal] Boot configuration — parameterized by BootLoader.

import Lean.Data.Json
import Types.Inductive.BootLoader.Default

/-- Boot configuration — parameterized by BootLoader. -/
structure BootConfig where
  enable : Bool := true
  loader : BootLoader := .systemdBoot
  efi : Bool := true
  kernelPackages : String := "default"
  initrdModules : List String := ["ahci", "xhci_pci", "virtio_pci", "virtio_blk", "sr_mod"]
  deriving Repr, Lean.ToJson, Lean.FromJson
