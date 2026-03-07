-- CoTypes/CoIO/ObservationSummary/Default.lean
-- CoIO — aggregate observation across all 7 phases.

import Lean.Data.Json
import CoTypes.CoIO.ObservationResult.Default
import CoTypes.Comonad.ObservationTrace.Default

/-- Aggregate observation across all 7 phases. -/
structure ObservationSummary where
  results : List ObservationResult := []
  totalPhases : Nat := 7
  passCount : Nat := 0
  failCount : Nat := 0
  skipCount : Nat := 0
  allPathsClosed : Bool := false
  trace : Option ObservationTrace := none
  deriving Repr, Lean.ToJson, Lean.FromJson
