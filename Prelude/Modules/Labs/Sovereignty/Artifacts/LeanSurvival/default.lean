-- Survival artifact — Tier 1 (4 params)
structure Survival where
  energy : Energy := {}
  water : Water := {}
  food : Food := {}
  shelter : Shelter := {}
  deriving Repr, BEq, Inhabited