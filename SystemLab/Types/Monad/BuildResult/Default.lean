-- Types/Monad/BuildResult/Default.lean
-- [Plasma] Build result — typed effect for Lake/Nix build outcomes.

import Lean.Data.Json

/-- Build result — typed effect for Lake/Nix build outcomes. -/
structure BuildResult where
  success : Bool
  artifactPath : String := ""
  errorMessage : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
