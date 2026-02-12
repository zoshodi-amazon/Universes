/-
  Sovereignty ADT — Complete ontology, decomposed into compact metric spaces

  Every sub-artifact has at most 7 parameters (cognitive bound).
  Each sub-artifact is its own bounded metric space with a 1-1 Monad.
  Defaults are the fixed point (center) of each metric space.

  Morphism chain:
    ADT (this file) -> Artifacts/default.nix -> default.json -> Monads (Lean folds) -> IO effects
-/

-- =============================================================================
-- UNITS (typed quantities — no raw strings)
-- =============================================================================

inductive MassUnit where | g | kg deriving Repr, BEq, Inhabited
inductive VolumeUnit where | mL | L deriving Repr, BEq, Inhabited
inductive TimeUnit where | s | min | hr deriving Repr, BEq, Inhabited
inductive PowerUnit where | mW | W | kW deriving Repr, BEq, Inhabited
inductive EnergyUnit where | Wh | kWh deriving Repr, BEq, Inhabited
inductive DistUnit where | m | km deriving Repr, BEq, Inhabited
inductive CapacityUnit where | mL | L | gal deriving Repr, BEq, Inhabited
inductive Currency where | USD | EUR | XMR | BTC | none deriving Repr, BEq, Inhabited

structure Mass where value : Float := 0.0; unit : MassUnit := .g deriving Repr, BEq, Inhabited
structure Vol where value : Float := 0.0; unit : VolumeUnit := .L deriving Repr, BEq, Inhabited
structure Duration where value : Float := 0.0; unit : TimeUnit := .min deriving Repr, BEq, Inhabited
structure Pow where value : Float := 0.0; unit : PowerUnit := .W deriving Repr, BEq, Inhabited
structure EnergyQty where value : Float := 0.0; unit : EnergyUnit := .Wh deriving Repr, BEq, Inhabited
structure Dist where value : Float := 0.0; unit : DistUnit := .m deriving Repr, BEq, Inhabited
structure Cap where value : Float := 0.0; unit : CapacityUnit := .L deriving Repr, BEq, Inhabited
structure Cost where value : Float := 0.0; currency : Currency := .USD deriving Repr, BEq, Inhabited

-- =============================================================================
-- SIGNATURE (5 params)
-- =============================================================================

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

-- =============================================================================
-- OPSEC (7 params)
-- =============================================================================

structure Opsec where
  physical : Bool := true
  signal : Bool := true
  digital : Bool := true
  social : Bool := false
  financial : Bool := true
  temporal : Bool := false
  legal : Bool := false
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- COMPETENCY + ACQUISITION
-- =============================================================================

inductive Competency where | untrained | novice | intermediate | proficient | expert deriving Repr, BEq, Inhabited
inductive AcqStatus where | needed | sourced | ordered | acquired | tested | deployed deriving Repr, BEq, Inhabited
inductive SourceType where | url (addr : String) | local (vendor : String) | diy | salvage | trade deriving Repr, BEq, Inhabited

-- =============================================================================
-- ITEM — decomposed into 3 sub-artifacts (was 11 params)
-- =============================================================================

/-- Identity: what is it (3 params) -/
structure ItemIdentity where
  name : String
  model : String
  qty : Nat := 1
  deriving Repr, BEq, Inhabited

/-- Physical: how much does it weigh/cost (4 params) -/
structure ItemPhysical where
  unitCost : Cost := {}
  weight : Mass := {}
  volume : Vol := {}
  packTime : Duration := {}
  deriving Repr, BEq, Inhabited

/-- Status: where is it in the lifecycle (4 params) -/
structure ItemStatus where
  source : SourceType := .diy
  status : AcqStatus := .needed
  competency : Competency := .untrained
  signature : Signature := {}
  deriving Repr, BEq, Inhabited

/-- Item: composed of 3 sub-artifacts (3 params) -/
structure Item where
  identity : ItemIdentity
  physical : ItemPhysical := {}
  lifecycle : ItemStatus := {}
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- ENERGY (4 params)
-- =============================================================================

inductive GenType where | solar | wind | hydro | thermal | manual | fuel deriving Repr, BEq, Inhabited
inductive Chemistry where | lifepo4 | liIon | leadAcid | supercap | mechanical deriving Repr, BEq, Inhabited
inductive Voltage where | v5 | v12 | v24 | v48 | v120 | v240 deriving Repr, BEq, Inhabited

structure Generation where
  types : List GenType := [.solar]
  capacity : Pow := { value := 100.0, unit := .W }
  items : List Item := []
  deriving Repr, BEq, Inhabited

structure Storage where
  capacity : EnergyQty := { value := 1.0, unit := .kWh }
  chemistry : Chemistry := .lifepo4
  items : List Item := []
  deriving Repr, BEq, Inhabited

structure Distribution where
  voltage : Voltage := .v12
  items : List Item := []
  deriving Repr, BEq, Inhabited

structure Energy where
  generation : Generation := {}
  storage : Storage := {}
  distribution : Distribution := {}
  signature : Signature := {}
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- WATER (5 params)
-- =============================================================================

inductive WaterSource where | rain | well | surface | atmospheric | recycled deriving Repr, BEq, Inhabited
inductive Purification where | filter | uv | boil | distill | reverseOsmosis | chemical deriving Repr, BEq, Inhabited

structure Water where
  sources : List WaterSource := [.rain]
  purification : List Purification := [.filter, .uv]
  capacity : Cap := { value := 100.0, unit := .L }
  signature : Signature := {}
  items : List Item := []
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- FOOD (5 params)
-- =============================================================================

inductive FoodAcquisition where | forage | hunt | fish | cultivate | trade | store deriving Repr, BEq, Inhabited
inductive Preservation where | dry | smoke | salt | ferment | freeze | can | vacuum deriving Repr, BEq, Inhabited
inductive CultivationMethod where | soil | hydroponic | aquaponic | aeroponic deriving Repr, BEq, Inhabited
inductive CultivationScale where | personal | family | community deriving Repr, BEq, Inhabited

structure Cultivation where
  method : CultivationMethod := .soil
  scale : CultivationScale := .personal
  items : List Item := []
  deriving Repr, BEq, Inhabited

structure Food where
  acquisition : List FoodAcquisition := [.store, .cultivate]
  preservation : List Preservation := [.dry, .vacuum]
  cultivation : Cultivation := {}
  signature : Signature := {}
  items : List Item := []
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- SHELTER (5 params)
-- =============================================================================

inductive ShelterType where | tent | vehicle | structure | underground | natural deriving Repr, BEq, Inhabited
inductive Mobility where | portable | relocatable | fixed deriving Repr, BEq, Inhabited
inductive ClimateControl where | none | passive | active deriving Repr, BEq, Inhabited

structure Climate where
  heating : ClimateControl := .passive
  cooling : ClimateControl := .passive
  deriving Repr, BEq, Inhabited

structure Shelter where
  shelterType : ShelterType := .tent
  mobility : Mobility := .portable
  climate : Climate := {}
  signature : Signature := {}
  items : List Item := []
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- MEDICAL (5 params)
-- =============================================================================

inductive MedicalLevel where | firstaid | emt | paramedic | fieldSurgery deriving Repr, BEq, Inhabited
inductive Diagnostic where | vitals | blood | imaging | lab deriving Repr, BEq, Inhabited

structure Pharmacy where
  synthesis : Bool := false
  botanical : Bool := false
  items : List Item := []
  deriving Repr, BEq, Inhabited

structure Medical where
  level : MedicalLevel := .firstaid
  pharmacy : Pharmacy := {}
  diagnostics : List Diagnostic := [.vitals]
  telemedicine : Bool := false
  items : List Item := []
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- COMMS (6 params)
-- =============================================================================

inductive MeshProtocol where | lora | meshtastic | reticulum | yggdrasil | cjdns deriving Repr, BEq, Inhabited
inductive Encryption where | none | aes256 | chacha20 | otp deriving Repr, BEq, Inhabited

structure Mesh where
  enable : Bool := false
  protocol : MeshProtocol := .meshtastic
  items : List Item := []
  deriving Repr, BEq, Inhabited

structure Burst where
  enable : Bool := false
  maxDuration : Duration := { value := 500.0, unit := .s }
  deriving Repr, BEq, Inhabited

structure RF where
  maxPower : Pow := { value := 100.0, unit := .mW }
  items : List Item := []
  deriving Repr, BEq, Inhabited

structure Comms where
  mesh : Mesh := {}
  burst : Burst := {}
  encryption : Encryption := .chacha20
  rf : RF := {}
  offline : Bool := false
  signature : Signature := {}
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- COMPUTE (6 params)
-- =============================================================================

inductive Arch where | riscv64 | aarch64 | x86_64 deriving Repr, BEq, Inhabited
inductive Openness where | full | partial | pragmatic deriving Repr, BEq, Inhabited
inductive KnowledgeSource where | wikipedia | wikibooks | stackexchange | arxiv | gutenberg deriving Repr, BEq, Inhabited
inductive DataDomain where | plants | chemicals | electronics | medical | geology | astronomy deriving Repr, BEq, Inhabited
inductive LLMModel where | llama7b | llama13b | mistral7b | phi2 | codellama deriving Repr, BEq, Inhabited

structure Knowledge where
  sources : List KnowledgeSource := [.wikipedia, .wikibooks, .stackexchange]
  llm : LLMModel := .llama7b
  domains : List DataDomain := [.plants, .chemicals, .electronics, .medical]
  items : List Item := []
  deriving Repr, BEq, Inhabited

structure Compute where
  architecture : Arch := .aarch64
  openness : Openness := .partial
  airgap : Bool := false
  disposable : Bool := false
  knowledge : Knowledge := {}
  items : List Item := []
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- INTELLIGENCE (4 params)
-- =============================================================================

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

-- =============================================================================
-- DEFENSE (4 params)
-- =============================================================================

inductive SensorType where | motion | seismic | acoustic | thermal | rf deriving Repr, BEq, Inhabited
inductive Hardening where | none | basic | reinforced | fortified deriving Repr, BEq, Inhabited
inductive Concealment where | none | camouflage | decoy | underground deriving Repr, BEq, Inhabited

structure Perimeter where enable : Bool := false; sensors : List SensorType := []; items : List Item := [] deriving Repr, BEq, Inhabited
structure EarlyWarning where enable : Bool := false; range : Dist := { value := 100.0, unit := .m }; items : List Item := [] deriving Repr, BEq, Inhabited
structure Physical where hardening : Hardening := .none; concealment : Concealment := .none; items : List Item := [] deriving Repr, BEq, Inhabited

structure Defense where
  perimeter : Perimeter := {}
  earlyWarning : EarlyWarning := {}
  physical : Physical := {}
  commsec : Bool := false
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- TRANSPORT (5 params)
-- =============================================================================

inductive TransportMode where | foot | bicycle | motorcycle | vehicle | boat | aircraft deriving Repr, BEq, Inhabited
inductive Fuel where | human | electric | gasoline | diesel | multi deriving Repr, BEq, Inhabited

structure Navigation where gps : Bool := false; gpsDenied : Bool := false; mapsOffline : Bool := false; items : List Item := [] deriving Repr, BEq, Inhabited

structure Transport where
  modes : List TransportMode := [.foot, .bicycle]
  fuel : Fuel := .human
  navigation : Navigation := {}
  signature : Signature := {}
  items : List Item := []
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- TRADE (4 params)
-- =============================================================================

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

-- =============================================================================
-- FABRICATION (4 params)
-- =============================================================================

inductive FabTier where | assembly | component | material deriving Repr, BEq, Inhabited
inductive FabMaterial where | plastic | metal | wood | ceramic | composite | electronic deriving Repr, BEq, Inhabited

structure FabCapabilities where
  printing3d : Bool := false; cnc : Bool := false; pcb : Bool := false; welding : Bool := false
  woodwork : Bool := false; textiles : Bool := false; chemistry : Bool := false
  deriving Repr, BEq, Inhabited

structure Fabrication where
  tier : FabTier := .assembly
  capabilities : FabCapabilities := {}
  materials : List FabMaterial := [.plastic]
  items : List Item := []
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- MODE CONSTRAINTS
-- =============================================================================

inductive BlendLevel where | tourist | resident | local | native deriving Repr, BEq, Inhabited
inductive InfraUse where | none | minimal | selective | full deriving Repr, BEq, Inhabited
inductive Permanence where | temporary | seasonal | semiPermanent | permanent deriving Repr, BEq, Inhabited
inductive Redundancy where | none | nPlus1 | twoN deriving Repr, BEq, Inhabited

structure NomadicConstraints where
  teardownTime : Duration := { value := 15.0, unit := .min }
  maxWeight : Mass := { value := 25.0, unit := .kg }
  maxVolume : Vol := { value := 65.0, unit := .L }
  mobility : TransportMode := .foot
  deriving Repr, BEq, Inhabited

structure UrbanConstraints where
  blendLevel : BlendLevel := .resident
  infrastructureUse : InfraUse := .selective
  burnerDevices : Bool := false
  realDevices : Bool := false
  deriving Repr, BEq, Inhabited

structure BaseConstraints where
  permanence : Permanence := .semiPermanent
  expansionCapacity : Nat := 4
  redundancy : Redundancy := .nPlus1
  cacheLocations : Nat := 0
  deriving Repr, BEq, Inhabited

structure ModeConstraints where
  nomadic : NomadicConstraints := {}
  urban : UrbanConstraints := {}
  base : BaseConstraints := {}
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- TIER SUB-ARTIFACTS (decompose 12 domains into 4 tiers, each <= 4 params)
-- =============================================================================

/-- Tier 1: Survival — spans all modes (4 params) -/
structure Survival where
  energy : Energy := {}
  water : Water := {}
  food : Food := {}
  shelter : Shelter := {}
  deriving Repr, BEq, Inhabited

/-- Tier 2: Infrastructure — required all modes, complexity varies (3 params) -/
structure Infrastructure where
  medical : Medical := {}
  comms : Comms := {}
  compute : Compute := {}
  deriving Repr, BEq, Inhabited

/-- Tier 3: Operations — mode-dependent intensity (2 params) -/
structure Operations where
  intelligence : Intelligence := {}
  defense : Defense := {}
  deriving Repr, BEq, Inhabited

/-- Tier 4: Expansion — most mode-specific (3 params) -/
structure Expansion where
  transport : Transport := {}
  trade : Trade := {}
  fabrication : Fabrication := {}
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- SOVEREIGNTY (top-level: 4 params — mode, bootstrap, opsec, constraints)
-- + 4 tier sub-artifacts = 4 + 4 = 8... decompose further
-- =============================================================================

inductive Mode where | nomadic | urban | base deriving Repr, BEq, Inhabited
inductive Bootstrap where | knowledge | energy | compute deriving Repr, BEq, Inhabited

/-- Global configuration (4 params) -/
structure SovGlobal where
  mode : Mode := .base
  bootstrap : Bootstrap := .knowledge
  opsec : Opsec := {}
  constraints : ModeConstraints := {}
  deriving Repr, BEq, Inhabited

/-- Domain space — all capability tiers (4 params) -/
structure Domains where
  survival : Survival := {}
  infrastructure : Infrastructure := {}
  operations : Operations := {}
  expansion : Expansion := {}
  deriving Repr, BEq, Inhabited

/-- Sovereignty — top-level (2 params) -/
structure Sovereignty where
  global : SovGlobal := {}
  domains : Domains := {}
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- IDENTIFIERS
-- =============================================================================

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

-- =============================================================================
-- ERRORS
-- =============================================================================

inductive SovError where
  | missingItems (domain : DomainId) (cap : CapId)
  | overWeight (actual : Mass) (limit : Mass)
  | overVolume (actual : Vol) (limit : Vol)
  | overPackTime (actual : Duration) (limit : Duration)
  | untrainedCapability (domain : DomainId) (cap : CapId) (level : Competency)
  | noBootstrapPath (seed : Bootstrap) (missing : List DomainId)
  | signatureExposure (domain : DomainId) (sig : Signature)
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- COMMANDS (every fold = a CLI command = a justfile recipe = a Monad)
-- =============================================================================

inductive Command where
  | status | gaps | bom | pack (mode : Mode) | cost | weight | signature
  | training | bootstrap | discover (domain : DomainId) | validate
  deriving Repr, BEq, Inhabited
