-- CoTypes/Comonad/CoBuildResult/Default.lean
-- Trace comonad — build observation.

import Lean.Data.Json

/-- Build observation — what we saw about a build after the fact.
    Dual of BuildResult (the effect of building). -/
structure CoBuildResult where
  observed : Bool := false
  artifactExists : Bool := false
  artifactPath : Option String := none
  deriving Repr, Lean.ToJson, Lean.FromJson
