-- Types/Product/User/Identity/Meta/Default.lean
-- [Gas] Product meta of User Identity sub-phase.
-- Stub: populated when observability requirements are defined.

import Lean.Data.Json

structure UserIdentityProductMeta where
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
