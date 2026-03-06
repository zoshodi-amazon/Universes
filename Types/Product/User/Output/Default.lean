-- Types/Product/User/Output/Default.lean
-- [Gas] Product output of User phase (top-level).
-- Migrated from: Modules/Types/PhaseOutputTypes/UserOutput/Default.lean

import Lean.Data.Json

structure UserProductOutput where
  activation : String
  deriving Repr, Lean.ToJson, Lean.FromJson
