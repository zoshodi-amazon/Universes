-- Types/Product/User/Packages/Meta/Default.lean
-- [Gas] Product meta of User Packages sub-phase.
-- Stub: populated when observability requirements are defined.

import Lean.Data.Json

structure UserPackagesProductMeta where
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
