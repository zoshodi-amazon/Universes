-- Types/Product/Network/Output/Default.lean
-- [Gas] Product output of Network phase.
-- Migrated from: Modules/Types/PhaseOutputTypes/NetworkOutput/Default.lean

import Lean.Data.Json

structure NetworkProductOutput where
  sshConfig : String
  firewallRules : String
  deriving Repr, Lean.ToJson, Lean.FromJson
