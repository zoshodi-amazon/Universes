-- Types/Inductive/HardwareProfile/Default.lean
-- [Crystalline] Hardware profile variants — drives automatic hardware configuration.

import Lean.Data.Json

/-- Hardware profile variants — drives automatic hardware configuration. -/
inductive HardwareProfile where
  | generic
  | laptop
  | desktop
  | server
  | vm
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson HardwareProfile where
  toJson
    | .generic => "generic"
    | .laptop => "laptop"
    | .desktop => "desktop"
    | .server => "server"
    | .vm => "vm"

instance : Lean.FromJson HardwareProfile where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "generic" => pure .generic
    | "laptop" => pure .laptop
    | "desktop" => pure .desktop
    | "server" => pure .server
    | "vm" => pure .vm
    | _ => throw s!"unknown HardwareProfile: {s}"
