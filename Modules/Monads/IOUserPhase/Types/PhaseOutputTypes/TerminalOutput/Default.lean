import Lean.Data.Json
structure TerminalOutput where
  tmuxConfig : String
  kittyConfig : String
  deriving Repr, Lean.ToJson, Lean.FromJson
