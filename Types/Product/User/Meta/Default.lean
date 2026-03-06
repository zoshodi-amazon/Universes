-- Types/Product/User/Meta/Default.lean
-- [Gas] Product meta of User phase.
-- Stub: populated when observability requirements are defined.

import Lean.Data.Json

structure UserProductMeta where
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
