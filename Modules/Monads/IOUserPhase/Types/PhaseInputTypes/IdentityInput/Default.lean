import Lean.Data.Json
structure IdentityInput where
  username : String := "zoshodi"
  homeDirectory : String := "/Users/zoshodi"
  stateVersion : String := "24.05"
  deriving Repr, Lean.ToJson, Lean.FromJson
