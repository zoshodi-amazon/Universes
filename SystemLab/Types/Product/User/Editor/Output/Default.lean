-- Types/Product/User/Editor/Output/Default.lean
-- [Gas] Product output of User Editor sub-phase.
-- Migrated from: Modules/Monads/IOUserPhase/Types/PhaseOutputTypes/EditorOutput/Default.lean

import Lean.Data.Json

structure UserEditorProductOutput where
  nixvimConfig : String
  deriving Repr, Lean.ToJson, Lean.FromJson
