-- Fabrication artifact (4 params)
inductive FabTier where | assembly | component | material deriving Repr, BEq, Inhabited
inductive FabMaterial where | plastic | metal | wood | ceramic | composite | electronic deriving Repr, BEq, Inhabited
structure FabCapabilities where printing3d : Bool := false; cnc : Bool := false; pcb : Bool := false; welding : Bool := false; woodwork : Bool := false; textiles : Bool := false; chemistry : Bool := false deriving Repr, BEq, Inhabited

structure Fabrication where
  tier : FabTier := .assembly
  capabilities : FabCapabilities := {}
  materials : List FabMaterial := [.plastic]
  items : List Item := []
  deriving Repr, BEq, Inhabited