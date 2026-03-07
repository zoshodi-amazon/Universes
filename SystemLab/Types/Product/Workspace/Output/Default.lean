-- Types/Product/Workspace/Output/Default.lean
-- [Gas] Product output of Workspace phase.
-- Migrated from: Modules/Types/PhaseOutputTypes/WorkspaceOutput/Default.lean

import Lean.Data.Json

structure WorkspaceProductOutput where
  devShells : List String
  sovereigntyConfig : String
  deriving Repr, Lean.ToJson, Lean.FromJson
