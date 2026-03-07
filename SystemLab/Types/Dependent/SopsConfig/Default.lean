-- Types/Dependent/SopsConfig/Default.lean
-- [Liquid Crystal] SOPS secret management configuration.

import Lean.Data.Json

/-- SOPS secret management configuration. -/
structure SopsConfig where
  enable : Bool := true
  ageKeyFile : String := "~/.config/sops/age/keys.txt"
  deriving Repr, Lean.ToJson, Lean.FromJson
