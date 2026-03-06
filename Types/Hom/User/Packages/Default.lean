-- Types/Hom/User/Packages/Default.lean
-- [Liquid] Morphism into User Packages sub-phase.
-- Migrated from: Modules/Monads/IOUserPhase/Types/PhaseInputTypes/PackagesInput/Default.lean

import Lean.Data.Json

structure UserPackagesHom where
  packages : List String := []
  deriving Repr, Lean.ToJson, Lean.FromJson
