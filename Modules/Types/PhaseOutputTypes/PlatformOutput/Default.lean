import Lean.Data.Json

structure PlatformOutput where
  kernel : String
  bootloader : String
  deriving Repr, Lean.ToJson, Lean.FromJson
