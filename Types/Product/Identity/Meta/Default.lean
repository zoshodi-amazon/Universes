-- Types/Product/Identity/Meta/Default.lean
-- [Gas] Product meta of Identity phase.
-- Stub: populated when observability requirements are defined.

import Lean.Data.Json

structure IdentityProductMeta where
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
