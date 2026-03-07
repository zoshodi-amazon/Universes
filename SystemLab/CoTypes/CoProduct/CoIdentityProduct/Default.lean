-- CoTypes/CoProduct/CoIdentityProduct/Default.lean
-- Coproduct — Identity phase product (output + meta).

import Lean.Data.Json
import CoTypes.CoProduct.CoIdentityOutput.Default
import CoTypes.CoProduct.CoObservationMeta.Default

structure CoIdentityProduct where
  observed : CoIdentityOutput := {}
  observation : CoObservationMeta := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
