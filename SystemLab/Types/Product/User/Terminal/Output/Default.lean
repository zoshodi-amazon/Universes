-- Types/Product/User/Terminal/Output/Default.lean
-- [Gas] Product output of User Terminal sub-phase.
-- Migrated from: Modules/Monads/IOUserPhase/Types/PhaseOutputTypes/TerminalOutput/Default.lean

import Lean.Data.Json

structure UserTerminalProductOutput where
  tmuxConfig : String
  kittyConfig : String
  deriving Repr, Lean.ToJson, Lean.FromJson
