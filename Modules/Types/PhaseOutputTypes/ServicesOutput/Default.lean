import Lean.Data.Json

structure ServicesOutput where
  containerConfigs : String
  deriving Repr, Lean.ToJson, Lean.FromJson
