-- Operations artifact — Tier 3 (2 params)
structure Operations where
  intelligence : Intelligence := {}
  defense : Defense := {}
  deriving Repr, BEq, Inhabited