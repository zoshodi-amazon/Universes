-- Item artifact — decomposed into 3 sub-artifacts (3 params)
inductive Competency where | untrained | novice | intermediate | proficient | expert deriving Repr, BEq, Inhabited
inductive AcqStatus where | needed | sourced | ordered | acquired | tested | deployed deriving Repr, BEq, Inhabited
inductive SourceType where | url (addr : String) | local (vendor : String) | diy | salvage | trade deriving Repr, BEq, Inhabited

inductive MassUnit where | g | kg deriving Repr, BEq, Inhabited
inductive VolumeUnit where | mL | L deriving Repr, BEq, Inhabited
inductive TimeUnit where | s | min | hr deriving Repr, BEq, Inhabited
inductive Currency where | USD | EUR | XMR | BTC | none deriving Repr, BEq, Inhabited

structure Mass where value : Float := 0.0; unit : MassUnit := .g deriving Repr, BEq, Inhabited
structure Vol where value : Float := 0.0; unit : VolumeUnit := .L deriving Repr, BEq, Inhabited
structure Duration where value : Float := 0.0; unit : TimeUnit := .min deriving Repr, BEq, Inhabited
structure Cost where value : Float := 0.0; currency : Currency := .USD deriving Repr, BEq, Inhabited

structure ItemIdentity where
  name : String
  model : String
  qty : Nat := 1
  deriving Repr, BEq, Inhabited

structure ItemPhysical where
  unitCost : Cost := {}
  weight : Mass := {}
  volume : Vol := {}
  packTime : Duration := {}
  deriving Repr, BEq, Inhabited

structure ItemStatus where
  source : SourceType := .diy
  status : AcqStatus := .needed
  competency : Competency := .untrained
  signature : Signature := {}
  deriving Repr, BEq, Inhabited

structure Item where
  identity : ItemIdentity
  physical : ItemPhysical := {}
  lifecycle : ItemStatus := {}
  deriving Repr, BEq, Inhabited