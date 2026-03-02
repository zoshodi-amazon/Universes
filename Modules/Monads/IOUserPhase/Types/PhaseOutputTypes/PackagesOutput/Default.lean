import Lean.Data.Json
structure PackagesOutput where
  homePackages : List String
  deriving Repr, Lean.ToJson, Lean.FromJson
