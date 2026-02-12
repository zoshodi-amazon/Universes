-- Sovereignty/Config.lean — FromJson for Item, domains, Sovereignty + loadConfig
import Sovereignty.Types
import Sovereignty.Json
import Lean.Data.Json
import Lean.Data.Json.Parser

open Lean Json

-- =============================================================================
-- ITEM
-- =============================================================================

instance : FromJson Item where
  fromJson? j := do
    let name ← j.getObjValAs? String "name"
    let model := (j.getObjValAs? String "model").toOption.getD ""
    return {
      name, model
      qty := (j.getObjValAs? Nat "qty").toOption.getD 1
      unitCost := (j.getObjValAs? Cost "unitCost").toOption.getD default
      weight := (j.getObjValAs? Mass "weight").toOption.getD default
      volume := (j.getObjValAs? Vol "volume").toOption.getD default
      packTime := (j.getObjValAs? Duration "packTime").toOption.getD default
      source := (j.getObjValAs? SourceType "source").toOption.getD .diy
      status := (j.getObjValAs? AcqStatus "status").toOption.getD .needed
      competency := (j.getObjValAs? Competency "competency").toOption.getD .untrained
      signature := (j.getObjValAs? Signature "signature").toOption.getD default
    }

private def getItems (j : Json) (key : String) : List Item :=
  (j.getObjValAs? (List Item) key).toOption.getD []

private def getSig (j : Json) : Signature :=
  (j.getObjValAs? Signature "signature").toOption.getD default

-- =============================================================================
-- ENERGY DOMAIN ENUMS
-- =============================================================================

instance : FromJson GenType where
  fromJson? j := do let s ← j.getStr?; return match s with
    | "solar" => .solar | "wind" => .wind | "hydro" => .hydro
    | "thermal" => .thermal | "manual" => .manual | "fuel" => .fuel | _ => .solar

instance : FromJson Chemistry where
  fromJson? j := do let s ← j.getStr?; return match s with
    | "lifepo4" => .lifepo4 | "li-ion" => .liIon | "lead-acid" => .leadAcid
    | "supercap" => .supercap | "mechanical" => .mechanical | _ => .lifepo4

instance : FromJson Voltage where
  fromJson? j := do let s ← j.getStr?; return match s with
    | "5V" => .v5 | "12V" => .v12 | "24V" => .v24 | "48V" => .v48 | "120V" => .v120 | "240V" => .v240 | _ => .v12

-- =============================================================================
-- DOMAIN STRUCTURES
-- =============================================================================

instance : FromJson Generation where
  fromJson? j := do return {
    types := (j.getObjValAs? (List GenType) "types").toOption.getD [.solar]
    capacity := (j.getObjValAs? Pow "capacity").toOption.getD { value := 100.0, unit := .W }
    items := getItems j "items"
  }

instance : FromJson Storage where
  fromJson? j := do return {
    capacity := (j.getObjValAs? EnergyQty "capacity").toOption.getD { value := 1.0, unit := .kWh }
    chemistry := (j.getObjValAs? Chemistry "chemistry").toOption.getD .lifepo4
    items := getItems j "items"
  }

instance : FromJson Distribution where
  fromJson? j := do return {
    voltage := (j.getObjValAs? Voltage "voltage").toOption.getD .v12
    items := getItems j "items"
  }

instance : FromJson Energy where
  fromJson? j := do return {
    generation := (j.getObjValAs? Generation "generation").toOption.getD default
    storage := (j.getObjValAs? Storage "storage").toOption.getD default
    distribution := (j.getObjValAs? Distribution "distribution").toOption.getD default
    signature := getSig j
  }

instance : FromJson Water where
  fromJson? j := do return {
    sources := default; purification := default
    capacity := (j.getObjValAs? Cap "capacity").toOption.getD default
    signature := getSig j; items := getItems j "items"
  }

instance : FromJson Cultivation where
  fromJson? j := do return { method := default; scale := default; items := getItems j "items" }

instance : FromJson Food where
  fromJson? j := do return {
    acquisition := default; preservation := default
    cultivation := (j.getObjValAs? Cultivation "cultivation").toOption.getD default
    signature := getSig j; items := getItems j "items"
  }

instance : FromJson Shelter where
  fromJson? j := do return {
    shelterType := default; mobility := default; climate := default
    signature := getSig j; items := getItems j "items"
  }

instance : FromJson Pharmacy where
  fromJson? j := do return { synthesis := default; botanical := default; items := getItems j "items" }

instance : FromJson Medical where
  fromJson? j := do return {
    level := default; pharmacy := (j.getObjValAs? Pharmacy "pharmacy").toOption.getD default
    diagnostics := default; telemedicine := default; items := getItems j "items"
  }

instance : FromJson Mesh where
  fromJson? j := do return { enable := default; protocol := default; items := getItems j "items" }

instance : FromJson RF where
  fromJson? j := do return { maxPower := default; items := getItems j "items" }

instance : FromJson Comms where
  fromJson? j := do return {
    mesh := (j.getObjValAs? Mesh "mesh").toOption.getD default
    burst := default; encryption := default
    rf := (j.getObjValAs? RF "rf").toOption.getD default
    offline := default; signature := getSig j
  }

instance : FromJson Compute where
  fromJson? j := do return {
    architecture := default; openness := default; airgap := default; disposable := default
    knowledge := default; items := getItems j "items"
  }

instance : FromJson Intelligence where
  fromJson? j := do return { osint := default; sigint := default; counterSurveillance := default; re := default }

instance : FromJson Defense where
  fromJson? j := do return { perimeter := default; earlyWarning := default; physical := default; commsec := default }

instance : FromJson Transport where
  fromJson? j := do return {
    modes := default; fuel := default; navigation := default
    signature := getSig j; items := getItems j "items"
  }

instance : FromJson Trade where
  fromJson? j := do return {
    methods := default; crypto := default; supplyChain := default; signature := getSig j
  }

instance : FromJson Fabrication where
  fromJson? j := do return { tier := default; capabilities := default; materials := default; items := getItems j "items" }

-- =============================================================================
-- MODE CONSTRAINTS
-- =============================================================================

instance : FromJson TransportMode where
  fromJson? j := do let s ← j.getStr?; return match s with
    | "foot" => .foot | "bicycle" => .bicycle | "motorcycle" => .motorcycle
    | "vehicle" => .vehicle | "boat" => .boat | "aircraft" => .aircraft | _ => .foot

instance : FromJson NomadicConstraints where
  fromJson? j := do return {
    teardownTime := (j.getObjValAs? Duration "teardownTime").toOption.getD default
    maxWeight := (j.getObjValAs? Mass "maxWeight").toOption.getD { value := 25.0, unit := .kg }
    maxVolume := (j.getObjValAs? Vol "maxVolume").toOption.getD { value := 65.0, unit := .L }
    mobility := (j.getObjValAs? TransportMode "mobility").toOption.getD .foot
  }

instance : FromJson UrbanConstraints where
  fromJson? j := do return default

instance : FromJson BaseConstraints where
  fromJson? j := do return default

instance : FromJson ModeConstraints where
  fromJson? j := do return {
    nomadic := (j.getObjValAs? NomadicConstraints "nomadic").toOption.getD default
    urban := (j.getObjValAs? UrbanConstraints "urban").toOption.getD default
    base := (j.getObjValAs? BaseConstraints "base").toOption.getD default
  }

-- =============================================================================
-- SOVEREIGNTY (top-level)
-- =============================================================================

instance : FromJson Sovereignty where
  fromJson? j := do return {
    mode := (j.getObjValAs? Mode "mode").toOption.getD .base
    bootstrap := (j.getObjValAs? Bootstrap "bootstrap").toOption.getD .knowledge
    opsec := (j.getObjValAs? Opsec "opsec").toOption.getD default
    constraints := (j.getObjValAs? ModeConstraints "constraints").toOption.getD default
    energy := (j.getObjValAs? Energy "energy").toOption.getD default
    water := (j.getObjValAs? Water "water").toOption.getD default
    food := (j.getObjValAs? Food "food").toOption.getD default
    shelter := (j.getObjValAs? Shelter "shelter").toOption.getD default
    medical := (j.getObjValAs? Medical "medical").toOption.getD default
    comms := (j.getObjValAs? Comms "comms").toOption.getD default
    compute := (j.getObjValAs? Compute "compute").toOption.getD default
    intelligence := (j.getObjValAs? Intelligence "intelligence").toOption.getD default
    defense := (j.getObjValAs? Defense "defense").toOption.getD default
    transport := (j.getObjValAs? Transport "transport").toOption.getD default
    trade := (j.getObjValAs? Trade "trade").toOption.getD default
    fabrication := (j.getObjValAs? Fabrication "fabrication").toOption.getD default
  }

-- =============================================================================
-- LOAD CONFIG (real implementation)
-- =============================================================================

def loadConfigFromJson (path : String) : IO Sovereignty := do
  let contents ← IO.FS.readFile path
  match Json.parse contents with
  | .error e => do
    IO.eprintln s!"JSON parse error: {e}"
    pure default
  | .ok json =>
    match FromJson.fromJson? json with
    | .error e => do
      IO.eprintln s!"Config deserialization error: {e}"
      pure default
    | .ok cfg => pure cfg
