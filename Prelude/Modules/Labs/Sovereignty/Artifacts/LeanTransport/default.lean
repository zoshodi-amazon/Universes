-- Transport artifact (5 params)
inductive TransportMode where | foot | bicycle | motorcycle | vehicle | boat | aircraft deriving Repr, BEq, Inhabited
inductive Fuel where | human | electric | gasoline | diesel | multi deriving Repr, BEq, Inhabited
structure Navigation where gps : Bool := false; gpsDenied : Bool := false; mapsOffline : Bool := false; items : List Item := [] deriving Repr, BEq, Inhabited

structure Transport where
  modes : List TransportMode := [.foot, .bicycle]
  fuel : Fuel := .human
  navigation : Navigation := {}
  signature : Signature := {}
  items : List Item := []
  deriving Repr, BEq, Inhabited