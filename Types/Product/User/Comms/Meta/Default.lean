-- Types/Product/User/Comms/Meta/Default.lean
-- [Gas] Product meta of User Comms sub-phase.
-- Stub: populated when observability requirements are defined.

import Lean.Data.Json

structure UserCommsProductMeta where
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
