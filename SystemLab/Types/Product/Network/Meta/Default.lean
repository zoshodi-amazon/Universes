-- Types/Product/Network/Meta/Default.lean
-- [Gas] Product meta of Network phase.
-- Stub: populated when observability requirements are defined.

import Lean.Data.Json

structure NetworkProductMeta where
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
