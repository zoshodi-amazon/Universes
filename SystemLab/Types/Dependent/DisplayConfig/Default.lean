-- Types/Dependent/DisplayConfig/Default.lean
-- [Liquid Crystal] Display configuration — parameterized by DisplayBackend + DisplayGreeter.

import Lean.Data.Json
import Types.Inductive.DisplayBackend.Default
import Types.Inductive.DisplayGreeter.Default

/-- Display configuration — parameterized by DisplayBackend + DisplayGreeter. -/
structure DisplayConfig where
  enable : Bool := false
  backend : DisplayBackend := .none
  greeter : DisplayGreeter := .none
  deriving Repr, Lean.ToJson, Lean.FromJson
