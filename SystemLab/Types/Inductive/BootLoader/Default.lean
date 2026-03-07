-- Types/Inductive/BootLoader/Default.lean
-- [Crystalline] Boot loader variants.

import Lean.Data.Json

/-- Boot loader variants. -/
inductive BootLoader where
  | systemdBoot
  | grub
  | none
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson BootLoader where
  toJson
    | .systemdBoot => "systemd-boot"
    | .grub => "grub"
    | .none => "none"

instance : Lean.FromJson BootLoader where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "systemd-boot" => pure .systemdBoot
    | "grub" => pure .grub
    | "none" => pure .none
    | _ => throw s!"unknown BootLoader: {s}"
