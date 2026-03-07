-- Types/Dependent/NetworkConfig/Default.lean
-- [Liquid Crystal] Network configuration.

import Lean.Data.Json

/-- Network configuration. -/
structure NetworkConfig where
  enable : Bool := true
  dhcp : Bool := true
  firewallEnable : Bool := true
  firewallPorts : List Nat := [22]
  ssh : Bool := true
  wireless : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
