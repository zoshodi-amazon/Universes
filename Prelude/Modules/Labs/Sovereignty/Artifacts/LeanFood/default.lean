-- Food artifact (5 params)
inductive FoodAcquisition where | forage | hunt | fish | cultivate | trade | store deriving Repr, BEq, Inhabited
inductive Preservation where | dry | smoke | salt | ferment | freeze | can | vacuum deriving Repr, BEq, Inhabited
inductive CultivationMethod where | soil | hydroponic | aquaponic | aeroponic deriving Repr, BEq, Inhabited
inductive CultivationScale where | personal | family | community deriving Repr, BEq, Inhabited

structure Cultivation where method : CultivationMethod := .soil; scale : CultivationScale := .personal; items : List Item := [] deriving Repr, BEq, Inhabited

structure Food where
  acquisition : List FoodAcquisition := [.store, .cultivate]
  preservation : List Preservation := [.dry, .vacuum]
  cultivation : Cultivation := {}
  signature : Signature := {}
  items : List Item := []
  deriving Repr, BEq, Inhabited