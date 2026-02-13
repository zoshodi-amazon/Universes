-- Trade artifact (4 params)
inductive TradeMethod where | barter | crypto | cash | commodity | service deriving Repr, BEq, Inhabited
inductive Coin where | btc | xmr | zec deriving Repr, BEq, Inhabited
structure CryptoConfig where enable : Bool := false; coins : List Coin := [.xmr]; coldStorage : Bool := false; items : List Item := [] deriving Repr, BEq, Inhabited
structure SupplyChain where verification : Bool := false; redundancy : Nat := 2 deriving Repr, BEq, Inhabited

structure Trade where
  methods : List TradeMethod := [.barter, .crypto]
  crypto : CryptoConfig := {}
  supplyChain : SupplyChain := {}
  signature : Signature := {}
  deriving Repr, BEq, Inhabited