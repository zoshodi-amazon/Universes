-- CoTypes/CoInductive/CoInductiveWitness/Default.lean
-- Coalgebraic dual of Inductive — elimination witness.

import Lean.Data.Json

/-- Elimination witness for an inductive ADT.
    Records whether a string successfully parsed to a valid constructor. -/
structure CoInductiveWitness where
  typeName : String
  rawValue : String
  valid : Bool := false
  normalizedValue : String := ""
  deriving Repr, Lean.ToJson, Lean.FromJson
