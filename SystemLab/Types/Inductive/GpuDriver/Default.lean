-- Types/Inductive/GpuDriver/Default.lean
-- [Crystalline] GPU driver variants.

import Lean.Data.Json

/-- GPU driver variants. -/
inductive GpuDriver where
  | none
  | intel
  | amd
  | nvidia
  | apple
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson GpuDriver where
  toJson
    | .none => "none"
    | .intel => "intel"
    | .amd => "amd"
    | .nvidia => "nvidia"
    | .apple => "apple"

instance : Lean.FromJson GpuDriver where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "none" => pure .none
    | "intel" => pure .intel
    | "amd" => pure .amd
    | "nvidia" => pure .nvidia
    | "apple" => pure .apple
    | _ => throw s!"unknown GpuDriver: {s}"
