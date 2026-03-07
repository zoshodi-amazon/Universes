-- Types/Inductive/PersistenceStrategy/Default.lean
-- [Crystalline] Persistence strategy variants.

import Lean.Data.Json

/-- Persistence strategy variants. -/
inductive PersistenceStrategy where
  | persistent
  | impermanent
  | ephemeral
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson PersistenceStrategy where
  toJson
    | .persistent => "persistent"
    | .impermanent => "impermanent"
    | .ephemeral => "ephemeral"

instance : Lean.FromJson PersistenceStrategy where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "persistent" => pure .persistent
    | "impermanent" => pure .impermanent
    | "ephemeral" => pure .ephemeral
    | _ => throw s!"unknown PersistenceStrategy: {s}"
