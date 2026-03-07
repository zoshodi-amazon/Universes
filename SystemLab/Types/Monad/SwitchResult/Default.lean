-- Types/Monad/SwitchResult/Default.lean
-- [Plasma] Switch result — typed effect for home-manager switch outcomes.

import Lean.Data.Json

/-- Switch result — typed effect for home-manager switch outcomes. -/
structure SwitchResult where
  success : Bool
  host : String
  errorMessage : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
