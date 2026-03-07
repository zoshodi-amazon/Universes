-- Types/Inductive/MachineArch/Default.lean
-- [Crystalline] Machine architecture variants.

import Lean.Data.Json

/-- Machine architecture variants. -/
inductive MachineArch where
  | x86_64
  | aarch64
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson MachineArch where
  toJson
    | .x86_64 => "x86_64"
    | .aarch64 => "aarch64"

instance : Lean.FromJson MachineArch where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "x86_64" => pure .x86_64
    | "aarch64" => pure .aarch64
    | _ => throw s!"unknown MachineArch: {s}"
