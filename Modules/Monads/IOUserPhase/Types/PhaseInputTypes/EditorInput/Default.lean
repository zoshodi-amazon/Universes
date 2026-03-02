import Lean.Data.Json
structure EditorInput where
  enable : Bool := true
  colorscheme : String := "tokyonight"
  leader : String := " "
  lineNumbers : Bool := true
  relativeNumbers : Bool := false
  tabWidth : Nat := 2
  deriving Repr, Lean.ToJson, Lean.FromJson
