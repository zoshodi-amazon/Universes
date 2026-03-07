-- Types/Inductive/CloudOutputFormat/Default.lean
-- [Crystalline] Cloud output format variants.

import Lean.Data.Json

/-- Cloud output format variants. -/
inductive CloudOutputFormat where
  | json
  | text
  | table
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson CloudOutputFormat where
  toJson
    | .json => "json"
    | .text => "text"
    | .table => "table"

instance : Lean.FromJson CloudOutputFormat where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "json" => pure .json
    | "text" => pure .text
    | "table" => pure .table
    | _ => throw s!"unknown CloudOutputFormat: {s}"
