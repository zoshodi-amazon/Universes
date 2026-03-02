import Lean.Data.Json

structure HomeTarget where
  enable : Bool := true
  username : String := "zoshodi"
  homeDirectory : String := "/home/zoshodi"
  stateVersion : String := "24.05"
  deriving Repr, Lean.ToJson, Lean.FromJson

structure HomeTargets where
  darwin : HomeTarget := { homeDirectory := "/Users/zoshodi" }
  cloudDev : HomeTarget := {}
  cloudNix : HomeTarget := { enable := false }
  deriving Repr, Lean.ToJson, Lean.FromJson

structure MachineConfig where
  name : String
  hostname : String
  arch : String := "x86_64"
  format : String := "vm"
  deriving Repr, Lean.ToJson, Lean.FromJson

structure DeployInput where
  home : HomeTargets := {}
  machines : List MachineConfig := []
  deriving Repr, Lean.ToJson, Lean.FromJson
