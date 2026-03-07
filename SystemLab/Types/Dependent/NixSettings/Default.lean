-- Types/Dependent/NixSettings/Default.lean
-- [Liquid Crystal] Nix daemon configuration — parameterized by GcInterval.

import Lean.Data.Json
import Types.Inductive.GcInterval.Default

/-- Nix daemon configuration — parameterized by GcInterval. -/
structure NixSettings where
  enable : Bool := true
  gcAutomatic : Bool := true
  gcInterval : GcInterval := .weekly
  gcOlderThan : String := "7d"
  optimise : Bool := true
  maxJobs : String := "auto"
  cores : Nat := 0
  deriving Repr, Lean.ToJson, Lean.FromJson
