-- Types/Hom/User/Editor/Default.lean
-- [Liquid] Morphism into User Editor sub-phase.
-- Migrated from: Modules/Monads/IOUserPhase/Types/PhaseInputTypes/EditorInput/Default.lean

import Lean.Data.Json
import Types.Inductive.Default

structure UserEditorHom where
  enable : Bool := true
  colorscheme : Colorscheme := .tokyonight
  leader : String := " "
  lineNumbers : Bool := true
  relativeNumbers : Bool := false
  tabWidth : Nat := 2
  deriving Repr, Lean.ToJson, Lean.FromJson
