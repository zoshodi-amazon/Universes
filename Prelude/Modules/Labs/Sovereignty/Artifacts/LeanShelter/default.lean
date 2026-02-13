-- Shelter artifact (5 params)
inductive ShelterType where | tent | vehicle | structure | underground | natural deriving Repr, BEq, Inhabited
inductive Mobility where | portable | relocatable | fixed deriving Repr, BEq, Inhabited
inductive ClimateControl where | none | passive | active deriving Repr, BEq, Inhabited
structure Climate where heating : ClimateControl := .passive; cooling : ClimateControl := .passive deriving Repr, BEq, Inhabited

structure Shelter where
  shelterType : ShelterType := .tent
  mobility : Mobility := .portable
  climate : Climate := {}
  signature : Signature := {}
  items : List Item := []
  deriving Repr, BEq, Inhabited