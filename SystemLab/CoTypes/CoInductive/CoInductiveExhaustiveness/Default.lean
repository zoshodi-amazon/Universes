-- CoTypes/CoInductive/CoInductiveExhaustiveness/Default.lean
-- Coalgebraic dual of Inductive — exhaustiveness record.

import Lean.Data.Json

/-- Exhaustiveness record — all valid constructors for an ADT. -/
structure CoInductiveExhaustiveness where
  typeName : String
  constructors : List String := []
  totalCount : Nat := 0
  deriving Repr, Lean.ToJson, Lean.FromJson
