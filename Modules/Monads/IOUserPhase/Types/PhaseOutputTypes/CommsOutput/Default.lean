import Lean.Data.Json
structure CommsOutput where
  firefoxConfig : String
  himalayaConfig : String
  opencodeConfig : String
  awscliConfig : String
  deriving Repr, Lean.ToJson, Lean.FromJson
