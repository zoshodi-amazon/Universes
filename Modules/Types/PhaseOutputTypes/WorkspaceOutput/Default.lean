import Lean.Data.Json

structure WorkspaceOutput where
  devShells : List String
  sovereigntyConfig : String
  deriving Repr, Lean.ToJson, Lean.FromJson
