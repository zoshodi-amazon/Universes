import Lean.Data.Json

structure NetworkOutput where
  sshConfig : String
  firewallRules : String
  deriving Repr, Lean.ToJson, Lean.FromJson
