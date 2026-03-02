import Lean.Data.Json

structure UserOutput where
  activation : String
  deriving Repr, Lean.ToJson, Lean.FromJson
