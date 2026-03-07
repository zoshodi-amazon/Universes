-- CoTypes/CoIO/ObservationResult/Default.lean
-- CoIO — result of a single phase observation.

import Lean.Data.Json
import CoTypes.CoIO.ObservationStatus.Default

/-- Result of a single phase observation.
    The primary output type for all CoIO executors. -/
structure ObservationResult where
  phase : String
  status : ObservationStatus := .skip
  schemaValid : Bool := false       -- path (a): schema observation
  runtimeValid : Bool := false      -- path (b): runtime observation
  pathsClosed : Bool := false       -- agreement between (a) and (b)
  message : String := ""
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
