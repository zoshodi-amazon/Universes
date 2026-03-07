-- Types/Identity/Phase/Default.lean
-- [BEC] A phase identity — one canonical representation per computation unit.

import Lean.Data.Json
import Types.Identity.Package.Default

/-- A phase identity — one canonical representation per computation unit. -/
structure Phase where
  inputs : List Package
  outputs : List String
  deriving Repr, Inhabited, Lean.ToJson, Lean.FromJson
