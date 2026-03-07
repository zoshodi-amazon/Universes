-- Types/Product/Workspace/Meta/Default.lean
-- [Gas] Product meta of Workspace phase.
-- Stub: populated when observability requirements are defined.

import Lean.Data.Json

structure WorkspaceProductMeta where
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
