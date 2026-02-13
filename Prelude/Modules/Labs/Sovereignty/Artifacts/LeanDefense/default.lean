-- Defense artifact (4 params)
inductive SensorType where | motion | seismic | acoustic | thermal | rf deriving Repr, BEq, Inhabited
inductive Hardening where | none | basic | reinforced | fortified deriving Repr, BEq, Inhabited
inductive Concealment where | none | camouflage | decoy | underground deriving Repr, BEq, Inhabited
inductive DistUnit where | m | km deriving Repr, BEq, Inhabited
structure Dist where value : Float := 0.0; unit : DistUnit := .m deriving Repr, BEq, Inhabited
structure Perimeter where enable : Bool := false; sensors : List SensorType := []; items : List Item := [] deriving Repr, BEq, Inhabited
structure EarlyWarning where enable : Bool := false; range : Dist := { value := 100.0, unit := .m }; items : List Item := [] deriving Repr, BEq, Inhabited
structure Physical where hardening : Hardening := .none; concealment : Concealment := .none; items : List Item := [] deriving Repr, BEq, Inhabited

structure Defense where
  perimeter : Perimeter := {}
  earlyWarning : EarlyWarning := {}
  physical : Physical := {}
  commsec : Bool := false
  deriving Repr, BEq, Inhabited