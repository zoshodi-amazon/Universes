import Lean.Data.Json
structure CredentialsInput where
  gitEnable : Bool := true
  gitUserName : String := ""
  gitUserEmail : String := ""
  gitDefaultBranch : String := "main"
  gitDelta : Bool := true
  gitLfs : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
