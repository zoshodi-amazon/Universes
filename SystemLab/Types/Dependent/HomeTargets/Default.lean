-- Types/Dependent/HomeTargets/Default.lean
-- [Liquid Crystal] Home targets — parameterized per deployment target.

import Lean.Data.Json
import Types.Dependent.HomeTarget.Default

/-- Home targets — parameterized per deployment target. -/
structure HomeTargets where
  darwin : HomeTarget := { homeDirectory := "/Users/zoshodi" }
  cloudDev : HomeTarget := {}
  cloudNix : HomeTarget := { enable := false }
  nixos : HomeTarget := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
