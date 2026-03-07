-- CoTypes/CoDependent/CoCloudConfig/Default.lean
-- Cofibration — observation of CloudConfig.

import Lean.Data.Json

/-- Observation of CloudConfig — lifting back to CloudOutputFormat fiber. -/
structure CoCloudConfig where
  enableObserved : Bool := false
  defaultRegionSet : Bool := false
  defaultOutputValid : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
