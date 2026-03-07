-- Types/Dependent/GitConfig/Default.lean
-- [Liquid Crystal] Git configuration.

import Lean.Data.Json
import Types.Inductive.GitBranch.Default

/-- Git configuration. -/
structure GitConfig where
  enable : Bool := true
  userName : String := ""
  userEmail : String := ""
  defaultBranch : GitBranch := .main
  delta : Bool := true
  lfs : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
