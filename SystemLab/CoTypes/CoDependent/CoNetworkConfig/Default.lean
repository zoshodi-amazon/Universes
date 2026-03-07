-- CoTypes/CoDependent/CoNetworkConfig/Default.lean
-- Cofibration — observation of NetworkConfig.

import Lean.Data.Json

/-- Observation of NetworkConfig. -/
structure CoNetworkConfig where
  enableObserved : Bool := false
  dhcpObserved : Bool := false
  firewallActive : Bool := false
  firewallPortsOpen : List Nat := []
  sshListening : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
