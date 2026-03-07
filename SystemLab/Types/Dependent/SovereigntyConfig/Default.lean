-- Types/Dependent/SovereigntyConfig/Default.lean
-- [Liquid Crystal] Sovereignty workspace configuration — parameterized by SovereigntyMode.

import Lean.Data.Json
import Types.Inductive.SovereigntyMode.Default

/-- Sovereignty workspace configuration — parameterized by SovereigntyMode. -/
structure SovereigntyConfig where
  mode : SovereigntyMode := .base
  bootstrapSeed : String := "knowledge"
  deriving Repr, Lean.ToJson, Lean.FromJson
