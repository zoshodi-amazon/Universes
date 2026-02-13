-- Infrastructure artifact — Tier 2 (3 params)
structure Infrastructure where
  medical : Medical := {}
  comms : Comms := {}
  compute : Compute := {}
  deriving Repr, BEq, Inhabited