-- CoTypes/CoProduct/CoObservationMeta/Default.lean
-- Coproduct — observation metadata common across all phases.

import Lean.Data.Json

/-- Observation metadata — common across all phases. -/
structure CoObservationMeta where
  observedAt : String := ""
  observerHost : String := ""
  durationMs : Nat := 0
  pathA : Bool := false  -- schema observation was performed
  pathB : Bool := false  -- runtime observation was performed
  pathsAgree : Bool := false  -- bidirectional path closure holds
  deriving Repr, Lean.ToJson, Lean.FromJson
