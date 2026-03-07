-- CoTypes/CoHom/CoPlatformHom/Default.lean
-- Observation specification for Platform phase.

import Lean.Data.Json
import CoTypes.CoDependent.CoBootConfig.Default
import CoTypes.CoDependent.CoDisplayConfig.Default

/-- Observation specification for Platform phase — what to check.
    Field-parallel to PlatformHom (boot, display). -/
structure CoPlatformHom where
  coBoot : CoBootConfig := {}
  coDisplay : CoDisplayConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
