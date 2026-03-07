-- CoTypes/CoDependent/CoBrowserConfig/Default.lean
-- Cofibration — observation of BrowserConfig.

import Lean.Data.Json

/-- Observation of BrowserConfig — lifting back to SearchEngine fiber. -/
structure CoBrowserConfig where
  enableObserved : Bool := false
  searchDefaultValid : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
