-- CoTypes/CoProduct/CoDeployProduct/Default.lean
-- Coproduct — Deploy phase product (output + meta).

import Lean.Data.Json
import CoTypes.CoProduct.CoDeployOutput.Default
import CoTypes.CoProduct.CoObservationMeta.Default

structure CoDeployProduct where
  observed : CoDeployOutput := {}
  observation : CoObservationMeta := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
