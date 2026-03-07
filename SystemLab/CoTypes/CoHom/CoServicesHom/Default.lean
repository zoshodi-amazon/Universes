-- CoTypes/CoHom/CoServicesHom/Default.lean
-- Observation specification for Services phase.

import Lean.Data.Json
import CoTypes.CoDependent.CoContainerConfig.Default

/-- Observation specification for Services phase — what to check.
    Field-parallel to ServicesHom (containers). -/
structure CoServicesHom where
  coContainers : CoContainerConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
