-- Types/Product/User/Credentials/Meta/Default.lean
-- [Gas] Product meta of User Credentials sub-phase.
-- Stub: populated when observability requirements are defined.

import Lean.Data.Json

structure UserCredentialsProductMeta where
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
