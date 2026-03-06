-- Types/Monad/Default.lean
-- [Plasma] Monad (M A) — Effect types.
-- Errors, build results, switch results — the typed effect vocabulary.
-- Terminal in the import DAG: may reference all lower layers.

import Lean.Data.Json

/-- Phase execution error — typed effect for pipeline failures. -/
structure PhaseError where
  phase : String
  message : String
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Build result — typed effect for Lake/Nix build outcomes. -/
structure BuildResult where
  success : Bool
  artifactPath : String := ""
  errorMessage : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Switch result — typed effect for home-manager switch outcomes. -/
structure SwitchResult where
  success : Bool
  host : String
  errorMessage : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Validation result — typed effect for JSON schema validation. -/
structure ValidationResult where
  phase : String
  valid : Bool
  errorMessage : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
