-- Types/Dependent/PersistenceConfig/Default.lean
-- [Liquid Crystal] Persistence configuration — parameterized by PersistenceStrategy.

import Lean.Data.Json
import Types.Inductive.PersistenceStrategy.Default

/-- Persistence configuration — parameterized by PersistenceStrategy. -/
structure PersistenceConfig where
  strategy : PersistenceStrategy := .persistent
  device : String := ""
  paths : List String := []
  deriving Repr, Lean.ToJson, Lean.FromJson
