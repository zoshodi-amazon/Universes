-- CoTypes/CoProduct/CoDeployOutput/Default.lean
-- Coproduct — observation output for Deploy phase.

import Lean.Data.Json

/-- Observation output for Deploy phase. -/
structure CoDeployOutput where
  homeConfigurations : List String := []
  nixosConfigurations : List String := []
  machineImages : List String := []
  deriving Repr, Lean.ToJson, Lean.FromJson
