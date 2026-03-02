import Lean.Data.Json

structure DeployOutput where
  home : List String
  machine : List String
  deriving Repr, Lean.ToJson, Lean.FromJson
