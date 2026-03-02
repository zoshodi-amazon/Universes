import Lean.Data.Json

structure BootConfig where
  enable : Bool := true
  loader : String := "systemd-boot"
  efi : Bool := true
  kernelPackages : String := "default"
  initrdModules : List String := ["ahci", "xhci_pci", "virtio_pci", "virtio_blk", "sr_mod"]
  deriving Repr, Lean.ToJson, Lean.FromJson

structure DisplayConfig where
  enable : Bool := false
  backend : String := "none"
  greeter : String := "none"
  deriving Repr, Lean.ToJson, Lean.FromJson

structure PlatformInput where
  boot : BootConfig := {}
  display : DisplayConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
