-- CoTypes/CoProduct/CoWorkspaceOutput/Default.lean
-- Coproduct — observation output for Workspace phase.

import Lean.Data.Json

/-- Observation output for Workspace phase. -/
structure CoWorkspaceOutput where
  devShellsAvailable : List String := []
  sovereigntyMode : Option String := none
  deriving Repr, Lean.ToJson, Lean.FromJson
