-- Opsec artifact (7 params)
structure Opsec where
  physical : Bool := true
  signal : Bool := true
  digital : Bool := true
  social : Bool := false
  financial : Bool := true
  temporal : Bool := false
  legal : Bool := false
  deriving Repr, BEq, Inhabited