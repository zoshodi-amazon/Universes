import Lean.Data.Json
structure ProgramConfig where
  name : String
  storePath : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
