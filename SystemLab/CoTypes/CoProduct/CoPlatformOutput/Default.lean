-- CoTypes/CoProduct/CoPlatformOutput/Default.lean
-- Coproduct — observation output for Platform phase.

import Lean.Data.Json

/-- Observation output for Platform phase. -/
structure CoPlatformOutput where
  kernelVersion : Option String := none
  bootloaderType : Option String := none
  displayBackend : Option String := none
  deriving Repr, Lean.ToJson, Lean.FromJson
