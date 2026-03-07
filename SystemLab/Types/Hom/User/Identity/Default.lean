-- Types/Hom/User/Identity/Default.lean
-- [Liquid] Morphism into User Identity sub-phase.
-- Migrated from: Modules/Monads/IOUserPhase/Types/PhaseInputTypes/IdentityInput/Default.lean

import Lean.Data.Json

structure UserIdentityHom where
  username : String := "zoshodi"
  homeDirectory : String := "/Users/zoshodi"
  stateVersion : String := "24.05"
  deriving Repr, Lean.ToJson, Lean.FromJson
