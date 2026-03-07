-- Types/Product/Identity/Output/Default.lean
-- [Gas] Product output of Identity phase.
-- Migrated from: Modules/Types/PhaseOutputTypes/IdentityOutput/Default.lean

import Lean.Data.Json

structure IdentityProductOutput where
  nixConf : String
  sopsKeys : String
  deriving Repr, Lean.ToJson, Lean.FromJson
