-- CoTypes/Comonad/CoSwitchResult/Default.lean
-- Trace comonad — switch observation.

import Lean.Data.Json

/-- Switch observation — what we saw about a switch after the fact.
    Dual of SwitchResult (the effect of switching). -/
structure CoSwitchResult where
  observed : Bool := false
  host : String := ""
  generationActive : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
