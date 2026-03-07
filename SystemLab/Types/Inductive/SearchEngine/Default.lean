-- Types/Inductive/SearchEngine/Default.lean
-- [Crystalline] Search engine variants.

import Lean.Data.Json

/-- Search engine variants. -/
inductive SearchEngine where
  | duckDuckGo
  | google
  | brave
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson SearchEngine where
  toJson
    | .duckDuckGo => "DuckDuckGo"
    | .google => "Google"
    | .brave => "Brave"

instance : Lean.FromJson SearchEngine where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "DuckDuckGo" => pure .duckDuckGo
    | "Google" => pure .google
    | "Brave" => pure .brave
    | _ => throw s!"unknown SearchEngine: {s}"
