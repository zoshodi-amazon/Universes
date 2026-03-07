-- Types/Inductive/AIProvider/Default.lean
-- [Crystalline] AI provider variants.

import Lean.Data.Json

/-- AI provider variants. -/
inductive AIProvider where
  | amazonBedrock
  | openai
  | anthropic
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson AIProvider where
  toJson
    | .amazonBedrock => "amazon-bedrock"
    | .openai => "openai"
    | .anthropic => "anthropic"

instance : Lean.FromJson AIProvider where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "amazon-bedrock" => pure .amazonBedrock
    | "openai" => pure .openai
    | "anthropic" => pure .anthropic
    | _ => throw s!"unknown AIProvider: {s}"
