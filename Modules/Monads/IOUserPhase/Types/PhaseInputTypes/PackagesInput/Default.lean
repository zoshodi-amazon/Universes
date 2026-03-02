import Lean.Data.Json
structure PackagesInput where
  packages : List String := []
  deriving Repr, Lean.ToJson, Lean.FromJson
