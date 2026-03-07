-- Types/Hom/User/Terminal/Default.lean
-- [Liquid] Morphism into User Terminal sub-phase.
-- Migrated from: Modules/Monads/IOUserPhase/Types/PhaseInputTypes/TerminalInput/Default.lean

import Lean.Data.Json
import Types.Inductive.Default

structure UserTerminalHom where
  tmuxEnable : Bool := true
  tmuxPrefix : TmuxPrefix := .ctrlA
  kittyEnable : Bool := true
  kittyTheme : KittyTheme := .tokyoNightNight
  deriving Repr, Lean.ToJson, Lean.FromJson
