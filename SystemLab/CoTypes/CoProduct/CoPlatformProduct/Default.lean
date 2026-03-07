-- CoTypes/CoProduct/CoPlatformProduct/Default.lean
-- Coproduct — Platform phase product (output + meta).

import Lean.Data.Json
import CoTypes.CoProduct.CoPlatformOutput.Default
import CoTypes.CoProduct.CoObservationMeta.Default

structure CoPlatformProduct where
  observed : CoPlatformOutput := {}
  observation : CoObservationMeta := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
