import Lean.Data.Json

structure NixSettings where
  enable : Bool := true
  gcAutomatic : Bool := true
  gcInterval : String := "weekly"
  gcOlderThan : String := "7d"
  optimise : Bool := true
  maxJobs : String := "auto"
  cores : Nat := 0
  deriving Repr, Lean.ToJson, Lean.FromJson

structure SopsConfig where
  enable : Bool := true
  ageKeyFile : String := "~/.config/sops/age/keys.txt"
  deriving Repr, Lean.ToJson, Lean.FromJson

structure IdentityInput where
  nixSettings : NixSettings := {}
  sops : SopsConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
