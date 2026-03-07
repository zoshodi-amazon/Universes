-- CoTypes/CoHom/CoIdentityHom/Default.lean
-- Observation specification for Identity phase.

import Lean.Data.Json
import CoTypes.CoDependent.CoNixSettings.Default
import CoTypes.CoDependent.CoSopsConfig.Default

/-- Observation specification for Identity phase — what to check.
    Field-parallel to IdentityHom (nixSettings, sops). -/
structure CoIdentityHom where
  coNixSettings : CoNixSettings := {}
  coSops : CoSopsConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
