-- Types/Dependent/Default.lean
-- [Liquid Crystal] Indexed / Fibered — parameterized config types.
-- These reference Identity and Inductive types. No upward imports.
-- Migrated from sub-structures in the old PhaseInputTypes.

import Lean.Data.Json
import Inductive.Default

/-- Nix daemon configuration — parameterized by GcInterval. -/
structure NixSettings where
  enable : Bool := true
  gcAutomatic : Bool := true
  gcInterval : GcInterval := .weekly
  gcOlderThan : String := "7d"
  optimise : Bool := true
  maxJobs : String := "auto"
  cores : Nat := 0
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- SOPS secret management configuration. -/
structure SopsConfig where
  enable : Bool := true
  ageKeyFile : String := "~/.config/sops/age/keys.txt"
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Boot configuration — parameterized by BootLoader. -/
structure BootConfig where
  enable : Bool := true
  loader : BootLoader := .systemdBoot
  efi : Bool := true
  kernelPackages : String := "default"
  initrdModules : List String := ["ahci", "xhci_pci", "virtio_pci", "virtio_blk", "sr_mod"]
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Display configuration — parameterized by DisplayBackend + DisplayGreeter. -/
structure DisplayConfig where
  enable : Bool := false
  backend : DisplayBackend := .none
  greeter : DisplayGreeter := .none
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Network configuration. -/
structure NetworkConfig where
  enable : Bool := true
  dhcp : Bool := true
  firewallEnable : Bool := true
  firewallPorts : List Nat := [22]
  ssh : Bool := true
  wireless : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- SSH configuration. -/
structure SshConfig where
  enable : Bool := true
  compression : Bool := true
  serverAliveInterval : Nat := 60
  serverAliveCountMax : Nat := 3
  forwardAgent : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Container configuration — parameterized by ContainerBackend. -/
structure ContainerConfig where
  enable : Bool := false
  backend : ContainerBackend := .podman
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Sovereignty workspace configuration — parameterized by SovereigntyMode. -/
structure SovereigntyConfig where
  mode : SovereigntyMode := .base
  bootstrapSeed : String := "knowledge"
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Git configuration. -/
structure GitConfig where
  enable : Bool := true
  userName : String := ""
  userEmail : String := ""
  defaultBranch : GitBranch := .main
  delta : Bool := true
  lfs : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Browser configuration — parameterized by SearchEngine. -/
structure BrowserConfig where
  enable : Bool := false
  searchDefault : SearchEngine := .duckDuckGo
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- AI assistant configuration — parameterized by AIProvider. -/
structure AIConfig where
  enable : Bool := true
  provider : AIProvider := .amazonBedrock
  region : String := "us-east-1"
  profile : String := "conduit"
  endpoint : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Cloud CLI configuration — parameterized by CloudOutputFormat. -/
structure CloudConfig where
  enable : Bool := true
  defaultRegion : String := "us-east-1"
  defaultOutput : CloudOutputFormat := .json
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Home target configuration. -/
structure HomeTarget where
  enable : Bool := true
  username : String := "zoshodi"
  homeDirectory : String := "/home/zoshodi"
  stateVersion : String := "24.05"
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Home targets — parameterized per deployment target. -/
structure HomeTargets where
  darwin : HomeTarget := { homeDirectory := "/Users/zoshodi" }
  cloudDev : HomeTarget := {}
  cloudNix : HomeTarget := { enable := false }
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Machine configuration — parameterized by MachineArch + MachineFormat. -/
structure MachineConfig where
  name : String
  hostname : String
  arch : MachineArch := .x86_64
  format : MachineFormat := .vm
  deriving Repr, Lean.ToJson, Lean.FromJson
