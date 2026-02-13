-- Intelligence artifact (4 params)
inductive OsintDomain where | social | geospatial | domain | image | video | document | darkweb deriving Repr, BEq, Inhabited
structure OSINT where enable : Bool := false; domains : List OsintDomain := [.social, .geospatial, .image]; items : List Item := [] deriving Repr, BEq, Inhabited
structure SIGINT where enable : Bool := false; sdr : Bool := false; spectrum : Bool := false; items : List Item := [] deriving Repr, BEq, Inhabited
structure CounterSurveillance where enable : Bool := false; rf : Bool := false; camera : Bool := false; items : List Item := [] deriving Repr, BEq, Inhabited
structure ReverseEngineering where software : Bool := false; hardware : Bool := false; firmware : Bool := false; items : List Item := [] deriving Repr, BEq, Inhabited

structure Intelligence where
  osint : OSINT := {}
  sigint : SIGINT := {}
  counterSurveillance : CounterSurveillance := {}
  re : ReverseEngineering := {}
  deriving Repr, BEq, Inhabited