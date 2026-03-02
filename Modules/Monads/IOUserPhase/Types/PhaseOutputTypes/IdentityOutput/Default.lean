import Lean.Data.Json
structure IdentityOutput where
  username : String
  homeDirectory : String
  stateVersion : String
  deriving Repr, Lean.ToJson, Lean.FromJson
