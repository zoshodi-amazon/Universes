-- Types/Inductive/SovereigntyMode/Default.lean
-- [Crystalline] Sovereignty mode variants.

import Lean.Data.Json

/-- Sovereignty mode variants. -/
inductive SovereigntyMode where
  | base
  | full
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson SovereigntyMode where
  toJson
    | .base => "base"
    | .full => "full"

instance : Lean.FromJson SovereigntyMode where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "base" => pure .base
    | "full" => pure .full
    | _ => throw s!"unknown SovereigntyMode: {s}"
