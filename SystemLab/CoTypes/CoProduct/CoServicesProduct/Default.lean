-- CoTypes/CoProduct/CoServicesProduct/Default.lean
-- Coproduct — Services phase product (output + meta).

import Lean.Data.Json
import CoTypes.CoProduct.CoServicesOutput.Default
import CoTypes.CoProduct.CoObservationMeta.Default

structure CoServicesProduct where
  observed : CoServicesOutput := {}
  observation : CoObservationMeta := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
