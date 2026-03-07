-- CoTypes/Comonad/Default.lean
-- Coalgebraic dual of Types/Monad/ — Trace comonad.
-- Where Monad types record effects that happened (errors, metrics, alarms),
-- Comonad types record the observation cursor state and history.
-- Duality: Effects ↔ Co-effects (traces)
--
-- Comonad laws (categorical dual of Monad):
--   extract : W A → A           (dual of return  : A → M A)
--   extend  : (W A → B) → W B   (dual of bind    : M A → (A → M B) → M B)

import Lean.Data.Json

/-- A single observation event in the trace. -/
structure ObservationEvent where
  phase : String
  timestamp : String := ""
  success : Bool := false
  message : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Observation trace — the comonad.
    `current` is `extract` (the focused observation).
    `history` is the context for `extend` (map over past observations). -/
structure ObservationTrace where
  current : ObservationEvent
  history : List ObservationEvent := []
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Extract the current observation from a trace (comonad extract). -/
def ObservationTrace.extract (w : ObservationTrace) : ObservationEvent :=
  w.current

/-- Push a new observation onto the trace, shifting current to history. -/
def ObservationTrace.push (w : ObservationTrace) (event : ObservationEvent) : ObservationTrace :=
  { current := event, history := w.current :: w.history }

/-- Observation error — the co-effect of a failed observation.
    Dual of PhaseError (the effect of a failed production). -/
structure ObservationError where
  phase : String
  message : String
  timestamp : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Build observation — what we saw about a build after the fact.
    Dual of BuildResult (the effect of building). -/
structure CoBuildResult where
  observed : Bool := false
  artifactExists : Bool := false
  artifactPath : Option String := none
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Switch observation — what we saw about a switch after the fact.
    Dual of SwitchResult (the effect of switching). -/
structure CoSwitchResult where
  observed : Bool := false
  host : String := ""
  generationActive : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson

/-- Validation observation — what we saw about a validation after the fact.
    Dual of ValidationResult (the effect of validating). -/
structure CoValidationResult where
  phase : String
  schemaConformant : Bool := false
  runtimeConformant : Bool := false
  pathsClosed : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
