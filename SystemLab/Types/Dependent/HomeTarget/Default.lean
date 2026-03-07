-- Types/Dependent/HomeTarget/Default.lean
-- [Liquid Crystal] Home target configuration.

import Lean.Data.Json

/-- Home target configuration. -/
structure HomeTarget where
  enable : Bool := true
  username : String := "zoshodi"
  homeDirectory : String := "/home/zoshodi"
  stateVersion : String := "24.05"
  deriving Repr, Lean.ToJson, Lean.FromJson
