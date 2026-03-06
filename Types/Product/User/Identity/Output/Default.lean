-- Types/Product/User/Identity/Output/Default.lean
-- [Gas] Product output of User Identity sub-phase.
-- Migrated from: Modules/Monads/IOUserPhase/Types/PhaseOutputTypes/IdentityOutput/Default.lean

import Lean.Data.Json

structure UserIdentityProductOutput where
  username : String
  homeDirectory : String
  stateVersion : String
  deriving Repr, Lean.ToJson, Lean.FromJson
