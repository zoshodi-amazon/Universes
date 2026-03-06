-- Types/Product/Deploy/Output/Default.lean
-- [Gas] Product output of Deploy phase.
-- Migrated from: Modules/Types/PhaseOutputTypes/DeployOutput/Default.lean

import Lean.Data.Json

structure DeployProductOutput where
  home : List String
  machine : List String
  deriving Repr, Lean.ToJson, Lean.FromJson
