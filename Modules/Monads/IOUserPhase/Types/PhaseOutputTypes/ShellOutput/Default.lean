import Lean.Data.Json
structure ShellOutput where
  zshConfig : String
  fishConfig : String
  nushellConfig : String
  direnvConfig : String
  starshipConfig : String
  deriving Repr, Lean.ToJson, Lean.FromJson
