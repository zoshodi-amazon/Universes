-- CoTypes/CoHom/CoDeployHom/Default.lean
-- Observation specification for Deploy phase.

import Lean.Data.Json
import CoTypes.CoDependent.CoHomeTarget.Default
import CoTypes.CoDependent.CoMachineConfig.Default

/-- Observation specification for Deploy phase — what to check.
    Field-parallel to DeployHom (home, machines). -/
structure CoDeployHom where
  coHomeDarwin : CoHomeTarget := {}
  coHomeCloudDev : CoHomeTarget := {}
  coHomeNixos : CoHomeTarget := {}
  coMachines : List CoMachineConfig := []
  deriving Repr, Lean.ToJson, Lean.FromJson
