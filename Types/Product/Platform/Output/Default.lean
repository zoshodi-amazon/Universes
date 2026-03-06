-- Types/Product/Platform/Output/Default.lean
-- [Gas] Product output of Platform phase.
-- Migrated from: Modules/Types/PhaseOutputTypes/PlatformOutput/Default.lean

import Lean.Data.Json

structure PlatformProductOutput where
  kernel : String
  bootloader : String
  deriving Repr, Lean.ToJson, Lean.FromJson
