-- Types/Dependent/CloudConfig/Default.lean
-- [Liquid Crystal] Cloud CLI configuration — parameterized by CloudOutputFormat.

import Lean.Data.Json
import Types.Inductive.CloudOutputFormat.Default

/-- Cloud CLI configuration — parameterized by CloudOutputFormat. -/
structure CloudConfig where
  enable : Bool := true
  defaultRegion : String := "us-east-1"
  defaultOutput : CloudOutputFormat := .json
  deriving Repr, Lean.ToJson, Lean.FromJson
