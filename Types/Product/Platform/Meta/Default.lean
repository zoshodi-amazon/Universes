-- Types/Product/Platform/Meta/Default.lean
-- [Gas] Product meta of Platform phase.
-- Stub: populated when observability requirements are defined.

import Lean.Data.Json

structure PlatformProductMeta where
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
