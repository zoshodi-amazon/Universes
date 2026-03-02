import Lean.Data.Json
structure CredentialsOutput where
  gitConfig : String
  deltaConfig : String
  deriving Repr, Lean.ToJson, Lean.FromJson
