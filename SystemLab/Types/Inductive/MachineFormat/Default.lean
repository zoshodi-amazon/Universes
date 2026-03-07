-- Types/Inductive/MachineFormat/Default.lean
-- [Crystalline] Machine format variants.

import Lean.Data.Json

/-- Machine format variants. -/
inductive MachineFormat where
  | vm
  | iso
  | microvm
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson MachineFormat where
  toJson
    | .vm => "vm"
    | .iso => "iso"
    | .microvm => "microvm"

instance : Lean.FromJson MachineFormat where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "vm" => pure .vm
    | "iso" => pure .iso
    | "microvm" => pure .microvm
    | _ => throw s!"unknown MachineFormat: {s}"
