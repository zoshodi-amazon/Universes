-- Types/Identity/Package/Default.lean
-- [BEC] A Nix store package — one canonical representation.

import Lean.Data.Json

/-- A Nix store package — one canonical representation. -/
structure Package where
  name : String
  storePath : String
  deriving Repr, Inhabited, BEq, Lean.ToJson, Lean.FromJson
