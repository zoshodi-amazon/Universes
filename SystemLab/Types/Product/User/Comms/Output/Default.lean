-- Types/Product/User/Comms/Output/Default.lean
-- [Gas] Product output of User Comms sub-phase.
-- Migrated from: Modules/Monads/IOUserPhase/Types/PhaseOutputTypes/CommsOutput/Default.lean

import Lean.Data.Json

structure UserCommsProductOutput where
  firefoxConfig : String
  himalayaConfig : String
  opencodeConfig : String
  awscliConfig : String
  deriving Repr, Lean.ToJson, Lean.FromJson
