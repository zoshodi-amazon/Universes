-- CoTypes/CoProduct/CoUserProduct/Default.lean
-- Coproduct — User phase product (output + meta).

import Lean.Data.Json
import CoTypes.CoProduct.CoUserOutput.Default
import CoTypes.CoProduct.CoObservationMeta.Default

structure CoUserProduct where
  observed : CoUserOutput := {}
  observation : CoObservationMeta := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
