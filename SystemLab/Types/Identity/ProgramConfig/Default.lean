-- Types/Identity/ProgramConfig/Default.lean
-- [BEC] A program configuration — one canonical representation.

import Lean.Data.Json

/-- A program configuration — one canonical representation. -/
structure ProgramConfig where
  name : String
  storePath : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
