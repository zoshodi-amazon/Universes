-- CoTypes/CoHom/CoNetworkHom/Default.lean
-- Observation specification for Network phase.

import Lean.Data.Json
import CoTypes.CoDependent.CoNetworkConfig.Default
import CoTypes.CoDependent.CoSshConfig.Default

/-- Observation specification for Network phase — what to check.
    Field-parallel to NetworkHom (network, ssh). -/
structure CoNetworkHom where
  coNetwork : CoNetworkConfig := {}
  coSsh : CoSshConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
