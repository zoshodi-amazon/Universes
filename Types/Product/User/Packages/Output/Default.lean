-- Types/Product/User/Packages/Output/Default.lean
-- [Gas] Product output of User Packages sub-phase.
-- Migrated from: Modules/Monads/IOUserPhase/Types/PhaseOutputTypes/PackagesOutput/Default.lean

import Lean.Data.Json

structure UserPackagesProductOutput where
  homePackages : List String
  deriving Repr, Lean.ToJson, Lean.FromJson
