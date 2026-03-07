-- Types/Product/Services/Output/Default.lean
-- [Gas] Product output of Services phase.
-- Migrated from: Modules/Types/PhaseOutputTypes/ServicesOutput/Default.lean

import Lean.Data.Json

structure ServicesProductOutput where
  containerConfigs : String
  deriving Repr, Lean.ToJson, Lean.FromJson
