-- Types/Identity/Default.lean
-- [BEC] Unit (⊤) — Terminal objects with exactly one canonical inhabitant.
-- Shared primitives referenced by all higher layers.
-- Merged from: Modules/Types/UnitTypes/Default.lean
--              Modules/Monads/IOUserPhase/Types/UnitTypes/Default.lean

import Lean.Data.Json

/-- A Nix store package — one canonical representation. -/
structure Package where
  name : String
  storePath : String
  deriving Repr, Inhabited, BEq, Lean.ToJson, Lean.FromJson

/-- A program configuration — one canonical representation. -/
structure ProgramConfig where
  name : String
  storePath : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- A phase identity — one canonical representation per computation unit. -/
structure Phase where
  inputs : List Package
  outputs : List String
  deriving Repr, Inhabited, Lean.ToJson, Lean.FromJson
