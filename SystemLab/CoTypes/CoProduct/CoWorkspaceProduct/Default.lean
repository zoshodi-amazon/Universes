-- CoTypes/CoProduct/CoWorkspaceProduct/Default.lean
-- Coproduct — Workspace phase product (output + meta).

import Lean.Data.Json
import CoTypes.CoProduct.CoWorkspaceOutput.Default
import CoTypes.CoProduct.CoObservationMeta.Default

structure CoWorkspaceProduct where
  observed : CoWorkspaceOutput := {}
  observation : CoObservationMeta := {}
  deriving Repr, Lean.ToJson, Lean.FromJson
