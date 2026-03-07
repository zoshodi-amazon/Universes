-- Types/Inductive/DisplayGreeter/Default.lean
-- [Crystalline] Display greeter variants.

import Lean.Data.Json

/-- Display greeter variants. -/
inductive DisplayGreeter where
  | greetd
  | gdm
  | none
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson DisplayGreeter where
  toJson
    | .greetd => "greetd"
    | .gdm => "gdm"
    | .none => "none"

instance : Lean.FromJson DisplayGreeter where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "greetd" => pure .greetd
    | "gdm" => pure .gdm
    | "none" => pure .none
    | _ => throw s!"unknown DisplayGreeter: {s}"
