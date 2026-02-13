-- Domains artifact (4 params)
structure Domains where
  survival : Survival := {}
  infrastructure : Infrastructure := {}
  operations : Operations := {}
  expansion : Expansion := {}
  deriving Repr, BEq, Inhabited