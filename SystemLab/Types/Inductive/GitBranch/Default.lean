-- Types/Inductive/GitBranch/Default.lean
-- [Crystalline] Git default branch variants.

import Lean.Data.Json

/-- Git default branch variants. -/
inductive GitBranch where
  | main
  | master
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson GitBranch where
  toJson
    | .main => "main"
    | .master => "master"

instance : Lean.FromJson GitBranch where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "main" => pure .main
    | "master" => pure .master
    | _ => throw s!"unknown GitBranch: {s}"
