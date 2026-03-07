-- CoTypes/CoIdentity/CoPackage/Default.lean
-- Coalgebraic dual of Identity — observation witness for a Nix store package.

import Lean.Data.Json

/-- Observation witness for a Nix store package — is it installed? -/
structure CoPackage where
  name : String
  installed : Bool := false
  storePathExists : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
