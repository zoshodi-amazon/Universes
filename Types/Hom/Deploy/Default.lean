-- Types/Hom/Deploy/Default.lean
-- [Liquid] Morphism into Deploy phase — home configurations, machines.
-- Migrated from: Modules/Types/PhaseInputTypes/DeployInput/Default.lean

import Lean.Data.Json
import Types.Dependent.Default

structure DeployHom where
  home : HomeTargets := {}
  machines : List MachineConfig := []
  deriving Repr, Lean.ToJson, Lean.FromJson
