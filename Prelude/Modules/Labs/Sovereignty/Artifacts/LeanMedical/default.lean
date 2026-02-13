-- Medical artifact (5 params)
inductive MedicalLevel where | firstaid | emt | paramedic | fieldSurgery deriving Repr, BEq, Inhabited
inductive Diagnostic where | vitals | blood | imaging | lab deriving Repr, BEq, Inhabited
structure Pharmacy where synthesis : Bool := false; botanical : Bool := false; items : List Item := [] deriving Repr, BEq, Inhabited

structure Medical where
  level : MedicalLevel := .firstaid
  pharmacy : Pharmacy := {}
  diagnostics : List Diagnostic := [.vitals]
  telemedicine : Bool := false
  items : List Item := []
  deriving Repr, BEq, Inhabited