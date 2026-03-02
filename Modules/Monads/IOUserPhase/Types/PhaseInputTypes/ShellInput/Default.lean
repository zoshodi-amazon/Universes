import Lean.Data.Json
structure ShellInput where
  editor : String := "nvim"
  visual : String := "nvim"
  zshEnable : Bool := true
  fishEnable : Bool := true
  nushellEnable : Bool := true
  direnvEnable : Bool := true
  deriving Repr, Lean.ToJson, Lean.FromJson
