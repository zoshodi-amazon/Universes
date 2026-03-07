-- Types/Inductive/AudioBackend/Default.lean
-- [Crystalline] Audio backend variants.

import Lean.Data.Json

/-- Audio backend variants. -/
inductive AudioBackend where
  | none
  | pipewire
  | pulseaudio
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson AudioBackend where
  toJson
    | .none => "none"
    | .pipewire => "pipewire"
    | .pulseaudio => "pulseaudio"

instance : Lean.FromJson AudioBackend where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "none" => pure .none
    | "pipewire" => pure .pipewire
    | "pulseaudio" => pure .pulseaudio
    | _ => throw s!"unknown AudioBackend: {s}"
