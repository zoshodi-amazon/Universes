import Lean.Data.Json

structure NetworkConfig where
  enable : Bool := true
  dhcp : Bool := true
  firewallEnable : Bool := true
  firewallPorts : List Nat := [22]
  ssh : Bool := true
  wireless : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

structure SshConfig where
  enable : Bool := true
  compression : Bool := true
  serverAliveInterval : Nat := 60
  serverAliveCountMax : Nat := 3
  forwardAgent : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

structure NetworkInput where
  network : NetworkConfig := {}
  ssh : SshConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
