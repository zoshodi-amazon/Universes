-- CoTypes/CoDependent/CoSovereigntyConfig/Default.lean
-- Cofibration — observation of SovereigntyConfig.

import Lean.Data.Json

/-- Observation of SovereigntyConfig — lifting back to SovereigntyMode fiber. -/
structure CoSovereigntyConfig where
  modeValid : Bool := false
  bootstrapSeedPresent : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
