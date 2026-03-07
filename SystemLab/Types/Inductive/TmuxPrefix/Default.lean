-- Types/Inductive/TmuxPrefix/Default.lean
-- [Crystalline] Tmux prefix key variants.

import Lean.Data.Json

/-- Tmux prefix key variants. -/
inductive TmuxPrefix where
  | ctrlA
  | ctrlB
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson TmuxPrefix where
  toJson
    | .ctrlA => "C-a"
    | .ctrlB => "C-b"

instance : Lean.FromJson TmuxPrefix where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "C-a" => pure .ctrlA
    | "C-b" => pure .ctrlB
    | _ => throw s!"unknown TmuxPrefix: {s}"
