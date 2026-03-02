import Lean.Data.Json

structure Package where
  name : String
  storePath : String
  deriving Repr, Inhabited, BEq, Lean.ToJson, Lean.FromJson

structure Phase where
  inputs : List Package
  outputs : List String
  deriving Repr, Inhabited, Lean.ToJson, Lean.FromJson
