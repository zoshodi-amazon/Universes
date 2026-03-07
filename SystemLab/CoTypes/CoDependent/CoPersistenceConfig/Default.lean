-- CoTypes/CoDependent/CoPersistenceConfig/Default.lean
-- Cofibration — observation of PersistenceConfig.

import Lean.Data.Json

/-- Observation of PersistenceConfig — lifting back to PersistenceStrategy fiber. -/
structure CoPersistenceConfig where
  strategyValid : Bool := false
  deviceMounted : Bool := false
  pathsExist : List Bool := []
  deriving Repr, Lean.ToJson, Lean.FromJson
