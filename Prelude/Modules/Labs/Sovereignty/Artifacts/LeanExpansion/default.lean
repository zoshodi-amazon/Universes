-- Expansion artifact — Tier 4 (3 params)
structure Expansion where
  transport : Transport := {}
  trade : Trade := {}
  fabrication : Fabrication := {}
  deriving Repr, BEq, Inhabited