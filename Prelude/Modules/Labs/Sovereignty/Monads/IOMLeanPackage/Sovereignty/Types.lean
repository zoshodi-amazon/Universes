-- Sovereignty/Types.lean — Full compilable ADT for sov CLI
-- Mirrors Universe/Core/Options/Sovereignty/default.lean (canonical)
-- Project-specific naming per Lake conventions (lives in Drv/)

-- =============================================================================
-- GLOBAL
-- =============================================================================

inductive Mode where | nomadic | urban | base deriving Repr, BEq, Inhabited
inductive Bootstrap where | knowledge | energy | compute deriving Repr, BEq, Inhabited
inductive FabTier where | assembly | component | material deriving Repr, BEq, Inhabited

instance : ToString Mode where
  toString | .nomadic => "nomadic" | .urban => "urban" | .base => "base"
instance : ToString Bootstrap where
  toString | .knowledge => "knowledge" | .energy => "energy" | .compute => "compute"
instance : ToString FabTier where
  toString | .assembly => "assembly" | .component => "component" | .material => "material"

-- =============================================================================
-- OPSEC
-- =============================================================================

inductive ThermalSig where | unmanaged | passive | active deriving Repr, BEq, Inhabited
inductive AcousticSig where | unmanaged | dampened | silent deriving Repr, BEq, Inhabited
inductive VisualSig where | visible | camouflaged | concealed deriving Repr, BEq, Inhabited
inductive ElectronicSig where | tracked | minimal | dark deriving Repr, BEq, Inhabited
inductive FinancialSig where | traceable | pseudonymous | anonymous deriving Repr, BEq, Inhabited

instance : ToString ThermalSig where toString | .unmanaged => "unmanaged" | .passive => "passive" | .active => "active"
instance : ToString AcousticSig where toString | .unmanaged => "unmanaged" | .dampened => "dampened" | .silent => "silent"
instance : ToString VisualSig where toString | .visible => "visible" | .camouflaged => "camouflaged" | .concealed => "concealed"
instance : ToString ElectronicSig where toString | .tracked => "tracked" | .minimal => "minimal" | .dark => "dark"
instance : ToString FinancialSig where toString | .traceable => "traceable" | .pseudonymous => "pseudonymous" | .anonymous => "anonymous"

structure Signature where
  thermal : ThermalSig := .unmanaged
  acoustic : AcousticSig := .unmanaged
  visual : VisualSig := .visible
  electronic : ElectronicSig := .minimal
  financial : FinancialSig := .traceable
  deriving Repr, BEq, Inhabited

structure Opsec where
  physical : Bool := true; signal : Bool := true; digital : Bool := true
  social : Bool := false; financial : Bool := true; temporal : Bool := false; legal : Bool := false
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- COMPETENCY
-- =============================================================================

inductive Competency where | untrained | novice | intermediate | proficient | expert deriving Repr, BEq, Inhabited

instance : ToString Competency where
  toString | .untrained => "untrained" | .novice => "novice" | .intermediate => "intermediate"
    | .proficient => "proficient" | .expert => "expert"

instance : Ord Competency where
  compare a b := compare (toNat a) (toNat b)
where
  toNat : Competency -> Nat
    | .untrained => 0 | .novice => 1 | .intermediate => 2 | .proficient => 3 | .expert => 4

def Competency.toNat : Competency -> Nat
  | .untrained => 0 | .novice => 1 | .intermediate => 2 | .proficient => 3 | .expert => 4

-- =============================================================================
-- UNITS
-- =============================================================================

inductive MassUnit where | g | kg deriving Repr, BEq, Inhabited
inductive VolumeUnit where | mL | L deriving Repr, BEq, Inhabited
inductive TimeUnit where | s | min | hr deriving Repr, BEq, Inhabited
inductive PowerUnit where | mW | W | kW deriving Repr, BEq, Inhabited
inductive EnergyUnit where | Wh | kWh deriving Repr, BEq, Inhabited
inductive DistUnit where | m | km deriving Repr, BEq, Inhabited
inductive CapacityUnit where | mL | L | gal deriving Repr, BEq, Inhabited
inductive Currency where | USD | EUR | XMR | BTC | none deriving Repr, BEq, Inhabited

instance : ToString MassUnit where toString | .g => "g" | .kg => "kg"
instance : ToString VolumeUnit where toString | .mL => "mL" | .L => "L"
instance : ToString TimeUnit where toString | .s => "s" | .min => "min" | .hr => "hr"
instance : ToString PowerUnit where toString | .mW => "mW" | .W => "W" | .kW => "kW"
instance : ToString EnergyUnit where toString | .Wh => "Wh" | .kWh => "kWh"
instance : ToString DistUnit where toString | .m => "m" | .km => "km"
instance : ToString CapacityUnit where toString | .mL => "mL" | .L => "L" | .gal => "gal"
instance : ToString Currency where toString | .USD => "USD" | .EUR => "EUR" | .XMR => "XMR" | .BTC => "BTC" | .none => "none"

structure Mass where value : Float := 0.0; unit : MassUnit := .g deriving Repr, BEq, Inhabited
structure Vol where value : Float := 0.0; unit : VolumeUnit := .L deriving Repr, BEq, Inhabited
structure Duration where value : Float := 0.0; unit : TimeUnit := .min deriving Repr, BEq, Inhabited
structure Pow where value : Float := 0.0; unit : PowerUnit := .W deriving Repr, BEq, Inhabited
structure EnergyQty where value : Float := 0.0; unit : EnergyUnit := .Wh deriving Repr, BEq, Inhabited
structure Dist where value : Float := 0.0; unit : DistUnit := .m deriving Repr, BEq, Inhabited
structure Cap where value : Float := 0.0; unit : CapacityUnit := .L deriving Repr, BEq, Inhabited
structure Cost where value : Float := 0.0; currency : Currency := .USD deriving Repr, BEq, Inhabited

instance : ToString Mass where toString m := s!"{m.value}{m.unit}"
instance : ToString Vol where toString v := s!"{v.value}{v.unit}"
instance : ToString Duration where toString d := s!"{d.value}{d.unit}"
instance : ToString Pow where toString p := s!"{p.value}{p.unit}"
instance : ToString EnergyQty where toString e := s!"{e.value}{e.unit}"
instance : ToString Dist where toString d := s!"{d.value}{d.unit}"
instance : ToString Cap where toString c := s!"{c.value}{c.unit}"
instance : ToString Cost where toString c := s!"{c.currency} {c.value}"

-- Normalize to base units for arithmetic
def Mass.toGrams (m : Mass) : Float := match m.unit with | .g => m.value | .kg => m.value * 1000.0
def Vol.toLiters (v : Vol) : Float := match v.unit with | .mL => v.value / 1000.0 | .L => v.value
def Duration.toMinutes (d : Duration) : Float := match d.unit with | .s => d.value / 60.0 | .min => d.value | .hr => d.value * 60.0
def Cost.toUSD (c : Cost) : Float := c.value -- simplified: assume USD for now

-- =============================================================================
-- ACQUISITION
-- =============================================================================

inductive AcqStatus where | needed | sourced | ordered | acquired | tested | deployed deriving Repr, BEq, Inhabited

instance : ToString AcqStatus where
  toString | .needed => "needed" | .sourced => "sourced" | .ordered => "ordered"
    | .acquired => "acquired" | .tested => "tested" | .deployed => "deployed"

def AcqStatus.isAcquired : AcqStatus -> Bool
  | .acquired | .tested | .deployed => true | _ => false

inductive SourceType where | url (addr : String) | local (vendor : String) | diy | salvage | trade deriving Repr, BEq, Inhabited

instance : ToString SourceType where
  toString | .url a => s!"url:{a}" | .local v => s!"local:{v}" | .diy => "diy" | .salvage => "salvage" | .trade => "trade"

-- =============================================================================
-- ITEM
-- =============================================================================

structure Item where
  name : String; model : String; qty : Nat := 1; unitCost : Cost := {}
  weight : Mass := {}; volume : Vol := {}; packTime : Duration := {}
  source : SourceType := .diy; status : AcqStatus := .needed
  competency : Competency := .untrained; signature : Signature := {}
  deriving Repr, BEq, Inhabited

def Item.totalWeight (i : Item) : Float := i.weight.toGrams * i.qty.toFloat
def Item.totalVolume (i : Item) : Float := i.volume.toLiters * i.qty.toFloat
def Item.totalCost (i : Item) : Float := i.unitCost.toUSD * i.qty.toFloat

-- =============================================================================
-- ENERGY (Tier 1)
-- =============================================================================

inductive GenType where | solar | wind | hydro | thermal | manual | fuel deriving Repr, BEq, Inhabited
inductive Chemistry where | lifepo4 | liIon | leadAcid | supercap | mechanical deriving Repr, BEq, Inhabited
inductive Voltage where | v5 | v12 | v24 | v48 | v120 | v240 deriving Repr, BEq, Inhabited

structure Generation where
  types : List GenType := [.solar]; capacity : Pow := { value := 100.0, unit := .W }; items : List Item := []
  deriving Repr, BEq, Inhabited
structure Storage where
  capacity : EnergyQty := { value := 1.0, unit := .kWh }; chemistry : Chemistry := .lifepo4; items : List Item := []
  deriving Repr, BEq, Inhabited
structure Distribution where
  voltage : Voltage := .v12; items : List Item := []
  deriving Repr, BEq, Inhabited
structure Energy where
  generation : Generation := {}; storage : Storage := {}; distribution : Distribution := {}; signature : Signature := {}
  deriving Repr, BEq, Inhabited

def Energy.allItems (e : Energy) : List Item := e.generation.items ++ e.storage.items ++ e.distribution.items

-- =============================================================================
-- WATER (Tier 1)
-- =============================================================================

inductive WaterSource where | rain | well | surface | atmospheric | recycled deriving Repr, BEq, Inhabited
inductive Purification where | filter | uv | boil | distill | reverseOsmosis | chemical deriving Repr, BEq, Inhabited

structure Water where
  sources : List WaterSource := [.rain]; purification : List Purification := [.filter, .uv]
  capacity : Cap := { value := 100.0, unit := .L }; signature : Signature := {}; items : List Item := []
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- FOOD (Tier 1)
-- =============================================================================

inductive FoodAcquisition where | forage | hunt | fish | cultivate | trade | store deriving Repr, BEq, Inhabited
inductive Preservation where | dry | smoke | salt | ferment | freeze | can | vacuum deriving Repr, BEq, Inhabited
inductive CultivationMethod where | soil | hydroponic | aquaponic | aeroponic deriving Repr, BEq, Inhabited
inductive CultivationScale where | personal | family | community deriving Repr, BEq, Inhabited

structure Cultivation where
  method : CultivationMethod := .soil; scale : CultivationScale := .personal; items : List Item := []
  deriving Repr, BEq, Inhabited
structure Food where
  acquisition : List FoodAcquisition := [.store, .cultivate]; preservation : List Preservation := [.dry, .vacuum]
  cultivation : Cultivation := {}; signature : Signature := {}; items : List Item := []
  deriving Repr, BEq, Inhabited

def Food.allItems (f : Food) : List Item := f.items ++ f.cultivation.items

-- =============================================================================
-- SHELTER (Tier 1)
-- =============================================================================

inductive ShelterType where | tent | vehicle | structure | underground | natural deriving Repr, BEq, Inhabited
inductive Mobility where | portable | relocatable | fixed deriving Repr, BEq, Inhabited
inductive ClimateControl where | none | passive | active deriving Repr, BEq, Inhabited

structure Climate where heating : ClimateControl := .passive; cooling : ClimateControl := .passive deriving Repr, BEq, Inhabited
structure Shelter where
  shelterType : ShelterType := .tent; mobility : Mobility := .portable; climate : Climate := {}
  signature : Signature := {}; items : List Item := []
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- MEDICAL (Tier 2)
-- =============================================================================

inductive MedicalLevel where | firstaid | emt | paramedic | fieldSurgery deriving Repr, BEq, Inhabited
inductive Diagnostic where | vitals | blood | imaging | lab deriving Repr, BEq, Inhabited

structure Pharmacy where synthesis : Bool := false; botanical : Bool := false; items : List Item := [] deriving Repr, BEq, Inhabited
structure Medical where
  level : MedicalLevel := .firstaid; pharmacy : Pharmacy := {}; diagnostics : List Diagnostic := [.vitals]
  telemedicine : Bool := false; items : List Item := []
  deriving Repr, BEq, Inhabited

def Medical.allItems (m : Medical) : List Item := m.items ++ m.pharmacy.items

-- =============================================================================
-- COMMS (Tier 2)
-- =============================================================================

inductive MeshProtocol where | lora | meshtastic | reticulum | yggdrasil | cjdns deriving Repr, BEq, Inhabited
inductive Encryption where | none | aes256 | chacha20 | otp deriving Repr, BEq, Inhabited

structure Mesh where enable : Bool := false; protocol : MeshProtocol := .meshtastic; items : List Item := [] deriving Repr, BEq, Inhabited
structure Burst where enable : Bool := false; maxDuration : Duration := { value := 500.0, unit := .s } deriving Repr, BEq, Inhabited
structure RF where maxPower : Pow := { value := 100.0, unit := .mW }; items : List Item := [] deriving Repr, BEq, Inhabited
structure Offline where sms : Bool := false; voice : Bool := false; data : Bool := false deriving Repr, BEq, Inhabited
structure Comms where
  mesh : Mesh := {}; burst : Burst := {}; encryption : Encryption := .chacha20
  rf : RF := {}; offline : Offline := {}; signature : Signature := {}
  deriving Repr, BEq, Inhabited

def Comms.allItems (c : Comms) : List Item := c.mesh.items ++ c.rf.items

-- =============================================================================
-- COMPUTE (Tier 2)
-- =============================================================================

inductive Arch where | riscv64 | aarch64 | x86_64 deriving Repr, BEq, Inhabited
inductive Openness where | full | partial | pragmatic deriving Repr, BEq, Inhabited
inductive KnowledgeSource where | wikipedia | wikibooks | stackexchange | arxiv | gutenberg deriving Repr, BEq, Inhabited
inductive DataDomain where | plants | chemicals | electronics | medical | geology | astronomy deriving Repr, BEq, Inhabited
inductive LLMModel where | llama7b | llama13b | mistral7b | phi2 | codellama deriving Repr, BEq, Inhabited

structure StaticKnowledge where enable : Bool := false; sources : List KnowledgeSource := [.wikipedia, .wikibooks, .stackexchange]; items : List Item := [] deriving Repr, BEq, Inhabited
structure LLM where enable : Bool := false; model : LLMModel := .llama7b; items : List Item := [] deriving Repr, BEq, Inhabited
structure StructuredKnowledge where enable : Bool := false; domains : List DataDomain := [.plants, .chemicals, .electronics, .medical]; items : List Item := [] deriving Repr, BEq, Inhabited
structure Knowledge where static : StaticKnowledge := {}; llm : LLM := {}; structured : StructuredKnowledge := {} deriving Repr, BEq, Inhabited
structure Compute where
  architecture : Arch := .aarch64; openness : Openness := .partial; airgap : Bool := false; disposable : Bool := false
  knowledge : Knowledge := {}; items : List Item := []
  deriving Repr, BEq, Inhabited

def Compute.allItems (c : Compute) : List Item :=
  c.items ++ c.knowledge.static.items ++ c.knowledge.llm.items ++ c.knowledge.structured.items

-- =============================================================================
-- INTELLIGENCE (Tier 3)
-- =============================================================================

inductive OsintDomain where | social | geospatial | domain | image | video | document | darkweb deriving Repr, BEq, Inhabited

structure OSINT where enable : Bool := false; domains : List OsintDomain := [.social, .geospatial, .image]; items : List Item := [] deriving Repr, BEq, Inhabited
structure SIGINT where enable : Bool := false; sdr : Bool := false; spectrum : Bool := false; protocol : Bool := false; items : List Item := [] deriving Repr, BEq, Inhabited
structure CounterSurveillance where enable : Bool := false; rf : Bool := false; camera : Bool := false; tscm : Bool := false; items : List Item := [] deriving Repr, BEq, Inhabited
structure ReverseEngineering where software : Bool := false; hardware : Bool := false; firmware : Bool := false; protocol : Bool := false; items : List Item := [] deriving Repr, BEq, Inhabited
structure Intelligence where
  osint : OSINT := {}; sigint : SIGINT := {}; counterSurveillance : CounterSurveillance := {}; re : ReverseEngineering := {}
  deriving Repr, BEq, Inhabited

def Intelligence.allItems (i : Intelligence) : List Item :=
  i.osint.items ++ i.sigint.items ++ i.counterSurveillance.items ++ i.re.items

-- =============================================================================
-- DEFENSE (Tier 3)
-- =============================================================================

inductive SensorType where | motion | seismic | acoustic | thermal | rf deriving Repr, BEq, Inhabited
inductive Hardening where | none | basic | reinforced | fortified deriving Repr, BEq, Inhabited
inductive Concealment where | none | camouflage | decoy | underground deriving Repr, BEq, Inhabited

structure Perimeter where enable : Bool := false; sensors : List SensorType := []; items : List Item := [] deriving Repr, BEq, Inhabited
structure EarlyWarning where enable : Bool := false; range : Dist := { value := 100.0, unit := .m }; items : List Item := [] deriving Repr, BEq, Inhabited
structure Physical where hardening : Hardening := .none; concealment : Concealment := .none; items : List Item := [] deriving Repr, BEq, Inhabited
structure Defense where
  perimeter : Perimeter := {}; earlyWarning : EarlyWarning := {}; physical : Physical := {}; commsec : Bool := false
  deriving Repr, BEq, Inhabited

def Defense.allItems (d : Defense) : List Item := d.perimeter.items ++ d.earlyWarning.items ++ d.physical.items

-- =============================================================================
-- TRANSPORT (Tier 4)
-- =============================================================================

inductive TransportMode where | foot | bicycle | motorcycle | vehicle | boat | aircraft deriving Repr, BEq, Inhabited
inductive Fuel where | human | electric | gasoline | diesel | multi deriving Repr, BEq, Inhabited

structure Navigation where gps : Bool := false; gpsDenied : Bool := false; mapsOffline : Bool := false; items : List Item := [] deriving Repr, BEq, Inhabited
structure Transport where
  modes : List TransportMode := [.foot, .bicycle]; fuel : Fuel := .human; navigation : Navigation := {}
  signature : Signature := {}; items : List Item := []
  deriving Repr, BEq, Inhabited

def Transport.allItems (t : Transport) : List Item := t.items ++ t.navigation.items

-- =============================================================================
-- TRADE (Tier 4)
-- =============================================================================

inductive TradeMethod where | barter | crypto | cash | commodity | service deriving Repr, BEq, Inhabited
inductive Coin where | btc | xmr | zec deriving Repr, BEq, Inhabited

structure CryptoConfig where enable : Bool := false; coins : List Coin := [.xmr]; coldStorage : Bool := false; items : List Item := [] deriving Repr, BEq, Inhabited
structure SupplyChain where verification : Bool := false; redundancy : Nat := 2 deriving Repr, BEq, Inhabited
structure Trade where
  methods : List TradeMethod := [.barter, .crypto]; crypto : CryptoConfig := {}; supplyChain : SupplyChain := {}; signature : Signature := {}
  deriving Repr, BEq, Inhabited

def Trade.allItems (t : Trade) : List Item := t.crypto.items

-- =============================================================================
-- FABRICATION (Tier 4)
-- =============================================================================

inductive FabMaterial where | plastic | metal | wood | ceramic | composite | electronic deriving Repr, BEq, Inhabited

structure FabCapabilities where
  printing3d : Bool := false; cnc : Bool := false; pcb : Bool := false; welding : Bool := false
  woodwork : Bool := false; textiles : Bool := false; chemistry : Bool := false; casting : Bool := false
  deriving Repr, BEq, Inhabited
structure Fabrication where
  tier : FabTier := .assembly; capabilities : FabCapabilities := {}; materials : List FabMaterial := [.plastic]; items : List Item := []
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
  blendLevel : BlendLevel := .resident; infrastructureUse : InfraUse := .selective
  burnerDevices : Bool := false; realDevices : Bool := false
  deriving Repr, BEq, Inhabited
structure BaseConstraints where
  permanence : Permanence := .semiPermanent; expansionCapacity : Nat := 4
  redundancy : Redundancy := .nPlus1; cacheLocations : Nat := 0
  deriving Repr, BEq, Inhabited
structure ModeConstraints where
  nomadic : NomadicConstraints := {}; urban : UrbanConstraints := {}; base : BaseConstraints := {}
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- SOVEREIGNTY
-- =============================================================================

structure Sovereignty where
  mode : Mode := .base; bootstrap : Bootstrap := .knowledge
  opsec : Opsec := {}; constraints : ModeConstraints := {}
  energy : Energy := {}; water : Water := {}; food : Food := {}; shelter : Shelter := {}
  medical : Medical := {}; comms : Comms := {}; compute : Compute := {}
  intelligence : Intelligence := {}; defense : Defense := {}
  transport : Transport := {}; trade : Trade := {}; fabrication : Fabrication := {}
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- IDENTIFIERS
-- =============================================================================

inductive DomainId where
  | energy | water | food | shelter | medical | comms
  | compute | intelligence | defense | transport | trade | fabrication
  deriving Repr, BEq, Inhabited

instance : ToString DomainId where
  toString | .energy => "energy" | .water => "water" | .food => "food"
    | .shelter => "shelter" | .medical => "medical" | .comms => "comms"
    | .compute => "compute" | .intelligence => "intelligence" | .defense => "defense"
    | .transport => "transport" | .trade => "trade" | .fabrication => "fabrication"

inductive CapId where
  | generation | storage | distribution | purification | waterStorage
  | acquisition | preservation | cultivation | climate | shelterStructure
  | pharmacy | diagnostics | telemedicine | mesh | burst | rf | offline
  | knowledge | airgap | disposable | osint | sigint | counterSurveillance | reverseEng
  | perimeter | earlyWarning | physical | commsec | navigation | mobility
  | cryptoTrade | supplyChain | fabCapability | materials
  deriving Repr, BEq, Inhabited

instance : ToString CapId where
  toString
    | .generation => "generation" | .storage => "storage" | .distribution => "distribution"
    | .purification => "purification" | .waterStorage => "water-storage"
    | .acquisition => "acquisition" | .preservation => "preservation" | .cultivation => "cultivation"
    | .climate => "climate" | .shelterStructure => "shelter-structure"
    | .pharmacy => "pharmacy" | .diagnostics => "diagnostics" | .telemedicine => "telemedicine"
    | .mesh => "mesh" | .burst => "burst" | .rf => "rf" | .offline => "offline"
    | .knowledge => "knowledge" | .airgap => "airgap" | .disposable => "disposable"
    | .osint => "osint" | .sigint => "sigint" | .counterSurveillance => "counter-surveillance" | .reverseEng => "reverse-eng"
    | .perimeter => "perimeter" | .earlyWarning => "early-warning" | .physical => "physical" | .commsec => "commsec"
    | .navigation => "navigation" | .mobility => "mobility"
    | .cryptoTrade => "crypto-trade" | .supplyChain => "supply-chain"
    | .fabCapability => "fab-capability" | .materials => "materials"

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

instance : ToString SovError where
  toString
    | .missingItems d c => s!"MISSING: {d}/{c}"
    | .overWeight a l => s!"OVERWEIGHT: {a} > {l}"
    | .overVolume a l => s!"OVERVOLUME: {a} > {l}"
    | .overPackTime a l => s!"SLOW_PACK: {a} > {l}"
    | .untrainedCapability d c l => s!"UNTRAINED: {d}/{c} (level: {l})"
    | .noBootstrapPath s m => s!"NO_BOOTSTRAP: seed={s} missing={m.length} domains"
    | .signatureExposure d _ => s!"SIGNATURE: {d} exposed"

-- =============================================================================
-- COMMANDS
-- =============================================================================

inductive Command where
  | status | gaps | bom | pack (mode : Mode) | cost | weight | signature
  | training | bootstrap | discover (domain : DomainId) | validate
  deriving Repr, BEq, Inhabited

-- =============================================================================
-- DOMAIN ITEM COLLECTION (total fold over the tree)
-- =============================================================================

def Sovereignty.allItems (cfg : Sovereignty) : List Item :=
  cfg.energy.allItems ++ cfg.water.items ++ cfg.food.allItems ++ cfg.shelter.items ++
  cfg.medical.allItems ++ cfg.comms.allItems ++ cfg.compute.allItems ++
  cfg.intelligence.allItems ++ cfg.defense.allItems ++
  cfg.transport.allItems ++ cfg.trade.allItems ++ cfg.fabrication.items

def Sovereignty.domainItems (cfg : Sovereignty) : List (DomainId × List Item) :=
  [ (.energy, cfg.energy.allItems), (.water, cfg.water.items), (.food, cfg.food.allItems)
  , (.shelter, cfg.shelter.items), (.medical, cfg.medical.allItems), (.comms, cfg.comms.allItems)
  , (.compute, cfg.compute.allItems), (.intelligence, cfg.intelligence.allItems)
  , (.defense, cfg.defense.allItems), (.transport, cfg.transport.allItems)
  , (.trade, cfg.trade.allItems), (.fabrication, cfg.fabrication.items) ]
