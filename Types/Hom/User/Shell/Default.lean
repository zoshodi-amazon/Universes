-- Types/Hom/User/Shell/Default.lean
-- [Liquid] Morphism into User Shell sub-phase.
-- Migrated from: Modules/Monads/IOUserPhase/Types/PhaseInputTypes/ShellInput/Default.lean

import Lean.Data.Json
import Inductive.Default

structure UserShellHom where
  editor : ShellEditor := .nvim
  visual : ShellEditor := .nvim
  zshEnable : Bool := true
  fishEnable : Bool := true
  nushellEnable : Bool := true
  direnvEnable : Bool := true
  deriving Repr, Lean.ToJson, Lean.FromJson
