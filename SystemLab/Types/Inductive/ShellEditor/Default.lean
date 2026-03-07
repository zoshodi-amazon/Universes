-- Types/Inductive/ShellEditor/Default.lean
-- [Crystalline] Default shell editor variants.

import Lean.Data.Json

/-- Default shell editor variants. -/
inductive ShellEditor where
  | nvim
  | vim
  | nano
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson ShellEditor where
  toJson
    | .nvim => "nvim"
    | .vim => "vim"
    | .nano => "nano"

instance : Lean.FromJson ShellEditor where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "nvim" => pure .nvim
    | "vim" => pure .vim
    | "nano" => pure .nano
    | _ => throw s!"unknown ShellEditor: {s}"
