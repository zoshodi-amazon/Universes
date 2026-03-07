-- Types/Dependent/AIConfig/Default.lean
-- [Liquid Crystal] AI assistant configuration — parameterized by AIProvider.

import Lean.Data.Json
import Types.Inductive.AIProvider.Default

/-- AI assistant configuration — parameterized by AIProvider. -/
structure AIConfig where
  enable : Bool := true
  provider : AIProvider := .amazonBedrock
  region : String := "us-east-1"
  profile : String := "conduit"
  endpoint : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
