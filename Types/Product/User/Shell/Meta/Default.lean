-- Types/Product/User/Shell/Meta/Default.lean
-- [Gas] Product meta of User Shell sub-phase.
-- Stub: populated when observability requirements are defined.

import Lean.Data.Json

structure UserShellProductMeta where
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
