-- CoTypes/CoProduct/CoNetworkOutput/Default.lean
-- Coproduct — observation output for Network phase.

import Lean.Data.Json

/-- Observation output for Network phase. -/
structure CoNetworkOutput where
  firewallActive : Bool := false
  openPorts : List Nat := []
  sshRunning : Bool := false
  sshMatchBlocks : List String := []
  deriving Repr, Lean.ToJson, Lean.FromJson
