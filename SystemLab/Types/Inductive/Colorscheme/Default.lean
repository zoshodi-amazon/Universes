-- Types/Inductive/Colorscheme/Default.lean
-- [Crystalline] Editor colorscheme variants.

import Lean.Data.Json

/-- Editor colorscheme variants. -/
inductive Colorscheme where
  | tokyonight
  | catppuccin
  | gruvbox
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson Colorscheme where
  toJson
    | .tokyonight => "tokyonight"
    | .catppuccin => "catppuccin"
    | .gruvbox => "gruvbox"

instance : Lean.FromJson Colorscheme where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "tokyonight" => pure .tokyonight
    | "catppuccin" => pure .catppuccin
    | "gruvbox" => pure .gruvbox
    | _ => throw s!"unknown Colorscheme: {s}"
