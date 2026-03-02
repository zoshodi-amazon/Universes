import Lean.Data.Json

structure IdentityOutput where
  nixConf : String
  sopsKeys : String
  deriving Repr, Lean.ToJson, Lean.FromJson
