-- Types/Inductive/DisplayBackend/Default.lean
-- [Crystalline] Display backend variants.

import Lean.Data.Json

/-- Display backend variants. -/
inductive DisplayBackend where
  | wayland
  | x11
  | none
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson DisplayBackend where
  toJson
    | .wayland => "wayland"
    | .x11 => "x11"
    | .none => "none"

instance : Lean.FromJson DisplayBackend where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "wayland" => pure .wayland
    | "x11" => pure .x11
    | "none" => pure .none
    | _ => throw s!"unknown DisplayBackend: {s}"
