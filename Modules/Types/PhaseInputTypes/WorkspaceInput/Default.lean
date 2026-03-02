import Lean.Data.Json

structure SovereigntyConfig where
  mode : String := "base"
  bootstrapSeed : String := "knowledge"
  deriving Repr, Lean.ToJson, Lean.FromJson

structure WorkspaceInput where
  sovereignty : SovereigntyConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
