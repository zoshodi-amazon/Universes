-- Types/Product/User/Credentials/Output/Default.lean
-- [Gas] Product output of User Credentials sub-phase.
-- Migrated from: Modules/Monads/IOUserPhase/Types/PhaseOutputTypes/CredentialsOutput/Default.lean

import Lean.Data.Json

structure UserCredentialsProductOutput where
  gitConfig : String
  deltaConfig : String
  deriving Repr, Lean.ToJson, Lean.FromJson
