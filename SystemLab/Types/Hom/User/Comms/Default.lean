-- Types/Hom/User/Comms/Default.lean
-- [Liquid] Morphism into User Comms sub-phase.
-- Migrated from: Modules/Monads/IOUserPhase/Types/PhaseInputTypes/CommsInput/Default.lean

import Lean.Data.Json
import Types.Inductive.Default

structure UserCommsHom where
  browserEnable : Bool := false
  aiEnable : Bool := true
  aiProvider : AIProvider := .amazonBedrock
  aiProfile : String := "conduit"
  cloudEnable : Bool := true
  mailEnable : Bool := true
  deriving Repr, Lean.ToJson, Lean.FromJson
