-- Sovereignty artifact — top-level (2 params)
structure Sovereignty where
  global : SovGlobal := {}
  domains : Domains := {}
  deriving Repr, BEq, Inhabited

-- Identifiers
inductive DomainId where
  | energy | water | food | shelter | medical | comms
  | compute | intelligence | defense | transport | trade | fabrication
  deriving Repr, BEq, Inhabited

inductive CapId where
  | generation | storage | distribution | purification | waterStorage
  | acquisition | preservation | cultivation | climate | shelterStructure
  | pharmacy | diagnostics | telemedicine | mesh | burst | rf | offline
  | knowledge | airgap | disposable | osint | sigint | counterSurveillance | reverseEng
  | perimeter | earlyWarning | physical | commsec | navigation | mobility
  | cryptoTrade | supplyChain | fabCapability | materials
  deriving Repr, BEq, Inhabited

-- Errors
inductive SovError where
  | missingItems (domain : DomainId) (cap : CapId)
  | overWeight (actual : Mass) (limit : Mass)
  | overVolume (actual : Vol) (limit : Vol)
  | overPackTime (actual : Duration) (limit : Duration)
  | untrainedCapability (domain : DomainId) (cap : CapId) (level : Competency)
  | noBootstrapPath (seed : Bootstrap) (missing : List DomainId)
  | signatureExposure (domain : DomainId) (sig : Signature)
  deriving Repr, BEq, Inhabited

-- Commands
inductive Command where
  | status | gaps | bom | pack (mode : Mode) | cost | weight | signature
  | training | bootstrap | discover (domain : DomainId) | validate
  deriving Repr, BEq, Inhabited