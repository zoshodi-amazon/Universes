-- CoTypes/CoProduct/CoUserOutput/Default.lean
-- Coproduct — observation output for User phase.

import Lean.Data.Json

/-- Observation output for User phase (top-level). -/
structure CoUserOutput where
  gitConfigured : Bool := false
  browserInstalled : Bool := false
  aiConfigured : Bool := false
  cloudConfigured : Bool := false
  deriving Repr, Lean.ToJson, Lean.FromJson
