-- Types/Product/User/Shell/Output/Default.lean
-- [Gas] Product output of User Shell sub-phase.
-- Migrated from: Modules/Monads/IOUserPhase/Types/PhaseOutputTypes/ShellOutput/Default.lean

import Lean.Data.Json

structure UserShellProductOutput where
  zshConfig : String
  fishConfig : String
  nushellConfig : String
  direnvConfig : String
  starshipConfig : String
  deriving Repr, Lean.ToJson, Lean.FromJson
