-- CoTypes/CoProduct/CoNetworkProduct/Default.lean
-- Coproduct — Network phase product (output + meta).

import Lean.Data.Json
import CoTypes.CoProduct.CoNetworkOutput.Default
import CoTypes.CoProduct.CoObservationMeta.Default

structure CoNetworkProduct where
  observed : CoNetworkOutput := {}
  observation : CoObservationMeta := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
