-- Energy artifact (4 params)
inductive GenType where | solar | wind | hydro | thermal | manual | fuel deriving Repr, BEq, Inhabited
inductive Chemistry where | lifepo4 | liIon | leadAcid | supercap | mechanical deriving Repr, BEq, Inhabited
inductive Voltage where | v5 | v12 | v24 | v48 | v120 | v240 deriving Repr, BEq, Inhabited
inductive PowerUnit where | mW | W | kW deriving Repr, BEq, Inhabited
inductive EnergyUnit where | Wh | kWh deriving Repr, BEq, Inhabited
structure Pow where value : Float := 0.0; unit : PowerUnit := .W deriving Repr, BEq, Inhabited
structure EnergyQty where value : Float := 0.0; unit : EnergyUnit := .Wh deriving Repr, BEq, Inhabited

structure Generation where types : List GenType := [.solar]; capacity : Pow := { value := 100.0, unit := .W }; items : List Item := [] deriving Repr, BEq, Inhabited
structure Storage where capacity : EnergyQty := { value := 1.0, unit := .kWh }; chemistry : Chemistry := .lifepo4; items : List Item := [] deriving Repr, BEq, Inhabited
structure Distribution where voltage : Voltage := .v12; items : List Item := [] deriving Repr, BEq, Inhabited

structure Energy where
  generation : Generation := {}
  storage : Storage := {}
  distribution : Distribution := {}
  signature : Signature := {}
  deriving Repr, BEq, Inhabited