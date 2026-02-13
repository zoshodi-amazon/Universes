-- Comms artifact (6 params)
inductive MeshProtocol where | lora | meshtastic | reticulum | yggdrasil | cjdns deriving Repr, BEq, Inhabited
inductive Encryption where | none | aes256 | chacha20 | otp deriving Repr, BEq, Inhabited
structure Mesh where enable : Bool := false; protocol : MeshProtocol := .meshtastic; items : List Item := [] deriving Repr, BEq, Inhabited
structure Burst where enable : Bool := false; maxDuration : Duration := { value := 500.0, unit := .s } deriving Repr, BEq, Inhabited
structure RF where maxPower : Pow := { value := 100.0, unit := .mW }; items : List Item := [] deriving Repr, BEq, Inhabited

structure Comms where
  mesh : Mesh := {}
  burst : Burst := {}
  encryption : Encryption := .chacha20
  rf : RF := {}
  offline : Bool := false
  signature : Signature := {}
  deriving Repr, BEq, Inhabited