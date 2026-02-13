-- Signature artifact (5 params)
inductive ThermalSig where | unmanaged | passive | active deriving Repr, BEq, Inhabited
inductive AcousticSig where | unmanaged | dampened | silent deriving Repr, BEq, Inhabited
inductive VisualSig where | visible | camouflaged | concealed deriving Repr, BEq, Inhabited
inductive ElectronicSig where | tracked | minimal | dark deriving Repr, BEq, Inhabited
inductive FinancialSig where | traceable | pseudonymous | anonymous deriving Repr, BEq, Inhabited

structure Signature where
  thermal : ThermalSig := .unmanaged
  acoustic : AcousticSig := .unmanaged
  visual : VisualSig := .visible
  electronic : ElectronicSig := .minimal
  financial : FinancialSig := .traceable
  deriving Repr, BEq, Inhabited