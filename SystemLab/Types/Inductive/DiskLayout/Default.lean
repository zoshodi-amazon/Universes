-- Types/Inductive/DiskLayout/Default.lean
-- [Crystalline] Disk layout strategy variants.

import Lean.Data.Json

/-- Disk layout strategy variants. -/
inductive DiskLayout where
  | standard
  | custom
  | none
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson DiskLayout where
  toJson
    | .standard => "standard"
    | .custom => "custom"
    | .none => "none"

instance : Lean.FromJson DiskLayout where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "standard" => pure .standard
    | "custom" => pure .custom
    | "none" => pure .none
    | _ => throw s!"unknown DiskLayout: {s}"
