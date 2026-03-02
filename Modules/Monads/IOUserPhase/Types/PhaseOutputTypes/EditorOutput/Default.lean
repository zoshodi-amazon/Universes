import Lean.Data.Json
structure EditorOutput where
  nixvimConfig : String
  deriving Repr, Lean.ToJson, Lean.FromJson
