import Lean.Data.Json
structure TerminalInput where
  tmuxEnable : Bool := true
  tmuxPrefix : String := "C-a"
  kittyEnable : Bool := true
  kittyTheme : String := "tokyo_night_night"
  deriving Repr, Lean.ToJson, Lean.FromJson
