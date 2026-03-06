-- Types/Product/User/Editor/Meta/Default.lean
-- [Gas] Product meta of User Editor sub-phase.
-- Stub: populated when observability requirements are defined.

import Lean.Data.Json

structure UserEditorProductMeta where
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
