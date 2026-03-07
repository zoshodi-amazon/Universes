-- CoTypes/CoDependent/CoNixSettings/Default.lean
-- Cofibration — observation of NixSettings.

import Lean.Data.Json

/-- Observation of NixSettings — lifting back to the GcInterval fiber. -/
structure CoNixSettings where
  enableObserved : Bool := false
  gcAutomaticObserved : Bool := false
  gcIntervalValid : Bool := false
  optimiseObserved : Bool := false
  maxJobsObserved : Option String := none
  coresObserved : Option Nat := none
  deriving Repr, Lean.ToJson, Lean.FromJson
