-- Water artifact (5 params)
inductive WaterSource where | rain | well | surface | atmospheric | recycled deriving Repr, BEq, Inhabited
inductive Purification where | filter | uv | boil | distill | reverseOsmosis | chemical deriving Repr, BEq, Inhabited
inductive CapacityUnit where | mL | L | gal deriving Repr, BEq, Inhabited
structure Cap where value : Float := 0.0; unit : CapacityUnit := .L deriving Repr, BEq, Inhabited

structure Water where
  sources : List WaterSource := [.rain]
  purification : List Purification := [.filter, .uv]
  capacity : Cap := { value := 100.0, unit := .L }
  signature : Signature := {}
  items : List Item := []
  deriving Repr, BEq, Inhabited