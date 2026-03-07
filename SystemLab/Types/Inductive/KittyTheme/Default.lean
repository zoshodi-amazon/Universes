-- Types/Inductive/KittyTheme/Default.lean
-- [Crystalline] Kitty terminal theme variants.

import Lean.Data.Json

/-- Kitty terminal theme variants. -/
inductive KittyTheme where
  | tokyoNightNight
  | catppuccinMocha
  | gruvboxDark
  deriving Repr, BEq, Inhabited

instance : Lean.ToJson KittyTheme where
  toJson
    | .tokyoNightNight => "tokyo_night_night"
    | .catppuccinMocha => "catppuccin_mocha"
    | .gruvboxDark => "gruvbox_dark"

instance : Lean.FromJson KittyTheme where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "tokyo_night_night" => pure .tokyoNightNight
    | "catppuccin_mocha" => pure .catppuccinMocha
    | "gruvbox_dark" => pure .gruvboxDark
    | _ => throw s!"unknown KittyTheme: {s}"
