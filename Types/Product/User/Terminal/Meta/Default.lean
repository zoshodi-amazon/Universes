-- Types/Product/User/Terminal/Meta/Default.lean
-- [Gas] Product meta of User Terminal sub-phase.
-- Stub: populated when observability requirements are defined.

import Lean.Data.Json

structure UserTerminalProductMeta where
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
