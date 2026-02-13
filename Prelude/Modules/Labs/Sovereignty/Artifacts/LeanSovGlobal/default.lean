-- SovGlobal artifact (4 params)
inductive Mode where | nomadic | urban | base deriving Repr, BEq, Inhabited
inductive Bootstrap where | knowledge | energy | compute deriving Repr, BEq, Inhabited

structure SovGlobal where
  mode : Mode := .base
  bootstrap : Bootstrap := .knowledge
  opsec : Opsec := {}
  constraints : ModeConstraints := {}
  deriving Repr, BEq, Inhabited