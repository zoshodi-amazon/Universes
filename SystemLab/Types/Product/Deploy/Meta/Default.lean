-- Types/Product/Deploy/Meta/Default.lean
-- [Gas] Product meta of Deploy phase.
-- Stub: populated when observability requirements are defined.

import Lean.Data.Json

structure DeployProductMeta where
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
