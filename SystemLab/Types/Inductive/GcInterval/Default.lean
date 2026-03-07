-- Types/Inductive/GcInterval/Default.lean
-- [Crystalline] Garbage collection interval variants.

import Lean.Data.Json

/-- Garbage collection interval variants. -/
inductive GcInterval where
  | daily
  | weekly
  | monthly
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson GcInterval where
  toJson
    | .daily => "daily"
    | .weekly => "weekly"
    | .monthly => "monthly"

instance : Lean.FromJson GcInterval where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "daily" => pure .daily
    | "weekly" => pure .weekly
    | "monthly" => pure .monthly
    | _ => throw s!"unknown GcInterval: {s}"
