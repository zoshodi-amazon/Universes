-- CoTypes/CoHom/CoWorkspaceHom/Default.lean
-- Observation specification for Workspace phase.

import Lean.Data.Json
import CoTypes.CoDependent.CoSovereigntyConfig.Default

/-- Observation specification for Workspace phase — what to check.
    Field-parallel to WorkspaceHom (sovereignty). -/
structure CoWorkspaceHom where
  coSovereignty : CoSovereigntyConfig := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
