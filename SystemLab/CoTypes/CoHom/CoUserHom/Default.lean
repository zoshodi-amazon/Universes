-- CoTypes/CoHom/CoUserHom/Default.lean
-- Observation specification for User phase.

import Lean.Data.Json
import CoTypes.CoDependent.CoGitConfig.Default
import CoTypes.CoDependent.CoBrowserConfig.Default
import CoTypes.CoDependent.CoAIConfig.Default
import CoTypes.CoDependent.CoCloudConfig.Default

/-- Observation specification for User phase (top-level) — what to check.
    Field-parallel to UserHom (git, browser, ai, cloud). -/
structure CoUserHom where
  coGit : CoGitConfig := {}
  coBrowser : CoBrowserConfig := {}
  coAi : CoAIConfig := {}
  coCloud : CoCloudConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
