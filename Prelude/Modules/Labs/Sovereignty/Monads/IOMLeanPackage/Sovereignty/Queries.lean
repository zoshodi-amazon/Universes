-- Sovereignty/Queries.lean — Full fold implementations over the ADT
import Sovereignty.Types
import Sovereignty.Config

-- =============================================================================
-- CORE FOLDS
-- =============================================================================

def totalWeight (items : List Item) : Float :=
  items.foldl (fun acc i => acc + i.totalWeight) 0.0

def totalVolume (items : List Item) : Float :=
  items.foldl (fun acc i => acc + i.totalVolume) 0.0

def totalCost (items : List Item) : Float :=
  items.foldl (fun acc i => acc + i.totalCost) 0.0

def acquiredItems (items : List Item) : List Item :=
  items.filter (·.status.isAcquired)

def neededItems (items : List Item) : List Item :=
  items.filter (fun i => !i.status.isAcquired)

def untrainedItems (items : List Item) : List Item :=
  items.filter (fun i => i.competency.toNat < Competency.toNat .intermediate)

-- =============================================================================
-- GAP ANALYSIS
-- =============================================================================

def gapDomains (cfg : Sovereignty) : List (DomainId × String) :=
  let check (d : DomainId) (cap : String) (items : List Item) (acc : List (DomainId × String)) :=
    if items.isEmpty then (d, cap) :: acc else acc
  let acc := []
  let acc := check .energy "generation" cfg.energy.generation.items acc
  let acc := check .energy "storage" cfg.energy.storage.items acc
  let acc := check .energy "distribution" cfg.energy.distribution.items acc
  let acc := check .water "water" cfg.water.items acc
  let acc := check .food "food" cfg.food.items acc
  let acc := check .food "cultivation" cfg.food.cultivation.items acc
  let acc := check .shelter "shelter" cfg.shelter.items acc
  let acc := check .medical "medical" cfg.medical.items acc
  let acc := check .medical "pharmacy" cfg.medical.pharmacy.items acc
  let acc := check .comms "mesh" cfg.comms.mesh.items acc
  let acc := check .comms "rf" cfg.comms.rf.items acc
  let acc := check .compute "compute" cfg.compute.items acc
  let acc := check .compute "static-knowledge" cfg.compute.knowledge.static.items acc
  let acc := check .compute "llm" cfg.compute.knowledge.llm.items acc
  let acc := check .intelligence "osint" cfg.intelligence.osint.items acc
  let acc := check .intelligence "sigint" cfg.intelligence.sigint.items acc
  let acc := check .intelligence "counter-surveillance" cfg.intelligence.counterSurveillance.items acc
  let acc := check .intelligence "reverse-eng" cfg.intelligence.re.items acc
  let acc := check .defense "perimeter" cfg.defense.perimeter.items acc
  let acc := check .defense "early-warning" cfg.defense.earlyWarning.items acc
  let acc := check .defense "physical" cfg.defense.physical.items acc
  let acc := check .transport "transport" cfg.transport.items acc
  let acc := check .transport "navigation" cfg.transport.navigation.items acc
  let acc := check .trade "crypto" cfg.trade.crypto.items acc
  let acc := check .fabrication "fabrication" cfg.fabrication.items acc
  acc.reverse

-- =============================================================================
-- PACK FILTER
-- =============================================================================

def packItems (cfg : Sovereignty) (mode : Mode) : List Item × List SovError :=
  let items := acquiredItems cfg.allItems
  match mode with
  | .nomadic =>
    let maxW := cfg.constraints.nomadic.maxWeight.toGrams
    let maxV := cfg.constraints.nomadic.maxVolume.toLiters
    let w := totalWeight items
    let v := totalVolume items
    let errs := (if w > maxW then [SovError.overWeight { value := w, unit := .g } cfg.constraints.nomadic.maxWeight] else [])
      ++ (if v > maxV then [SovError.overVolume { value := v, unit := .L } cfg.constraints.nomadic.maxVolume] else [])
    (items, errs)
  | .urban => (items, [])
  | .base => (items, [])

-- =============================================================================
-- SIGNATURE AGGREGATION
-- =============================================================================

def worstThermal : ThermalSig -> ThermalSig -> ThermalSig
  | .active, _ | _, .active => .active
  | .passive, _ | _, .passive => .passive
  | _, _ => .unmanaged

def worstVisual : VisualSig -> VisualSig -> VisualSig
  | .visible, _ | _, .visible => .visible
  | .camouflaged, _ | _, .camouflaged => .camouflaged
  | _, _ => .concealed

def aggregateSignature (cfg : Sovereignty) : Signature :=
  let sigs := [cfg.energy.signature, cfg.water.signature, cfg.food.signature,
    cfg.shelter.signature, cfg.comms.signature, cfg.transport.signature, cfg.trade.signature]
  sigs.foldl (fun acc s => {
    thermal := worstThermal acc.thermal s.thermal
    acoustic := acc.acoustic
    visual := worstVisual acc.visual s.visual
    electronic := acc.electronic
    financial := acc.financial
  }) default

-- =============================================================================
-- VALIDATION
-- =============================================================================

def validateAll (cfg : Sovereignty) : List SovError :=
  let gaps := gapDomains cfg |>.map fun (d, c) => SovError.missingItems d (CapId.generation) -- simplified cap mapping
  let untrained := untrainedItems cfg.allItems |>.map fun i =>
    SovError.untrainedCapability .energy .generation i.competency -- simplified domain mapping
  gaps ++ untrained

-- =============================================================================
-- CONFIG LOADING
-- =============================================================================

def loadConfig (path : String) : IO Sovereignty :=
  loadConfigFromJson path

-- =============================================================================
-- OUTPUT FORMATTING
-- =============================================================================

def printTable (header : String) (rows : List (String × String)) : IO Unit := do
  IO.println s!"=== {header} ==="
  for (k, v) in rows do
    IO.println s!"  {k}: {v}"
  IO.println ""

def printItems (label : String) (items : List Item) : IO Unit := do
  IO.println s!"=== {label} ({items.length} items) ==="
  for i in items do
    let statusMark := if i.status.isAcquired then "[x]" else "[ ]"
    IO.println s!"  {statusMark} {i.name} ({i.model}) x{i.qty} | {i.weight} | {i.unitCost} | {i.competency} | {i.status}"
  IO.println ""

-- =============================================================================
-- DISPATCH (exhaustive — adding a Command constructor without a case = compile error)
-- =============================================================================

def dispatch (cfg : Sovereignty) (cmd : Command) : IO Unit :=
  match cmd with
  | .status => do
    let items := cfg.allItems
    let acq := acquiredItems items
    IO.println s!"=== Sovereignty Status ==="
    IO.println s!"  Mode: {cfg.mode} | Bootstrap: {cfg.bootstrap}"
    IO.println s!"  Items: {acq.length}/{items.length} acquired"
    IO.println s!"  Weight: {totalWeight acq}g | Cost: ${totalCost items}"
    IO.println ""
    IO.println "  Domain Coverage:"
    for (d, ditems) in cfg.domainItems do
      let a := (acquiredItems ditems).length
      let t := ditems.length
      let mark := if t == 0 then "---" else if a == t then "[=]" else "[.]"
      IO.println s!"    {mark} {d}: {a}/{t}"
  | .gaps => do
    let gaps := gapDomains cfg
    IO.println s!"=== Gaps ({gaps.length} capabilities uncovered) ==="
    for (d, c) in gaps do
      IO.println s!"  [ ] {d}/{c}"
  | .bom => do
    let items := cfg.allItems
    printItems "Bill of Materials" items
    IO.println s!"  Total items: {items.length}"
    IO.println s!"  Total cost: ${totalCost items}"
    IO.println s!"  Total weight: {totalWeight items}g"
  | .cost => do
    IO.println "=== Cost Breakdown ==="
    for (d, ditems) in cfg.domainItems do
      let c := totalCost ditems
      if c > 0.0 then IO.println s!"  {d}: ${c}"
    IO.println s!"  TOTAL: ${totalCost cfg.allItems}"
  | .weight => do
    IO.println "=== Weight Breakdown ==="
    for (d, ditems) in cfg.domainItems do
      let w := totalWeight ditems
      if w > 0.0 then IO.println s!"  {d}: {w}g"
    IO.println s!"  TOTAL: {totalWeight cfg.allItems}g"
  | .signature => do
    let sig := aggregateSignature cfg
    printTable "OPSEC Signature" [
      ("thermal", toString sig.thermal), ("acoustic", toString sig.acoustic),
      ("visual", toString sig.visual), ("electronic", toString sig.electronic),
      ("financial", toString sig.financial)]
  | .training => do
    let items := untrainedItems cfg.allItems
    printItems "Training Needed (competency < intermediate)" items
  | .bootstrap => do
    let gaps := gapDomains cfg
    IO.println s!"=== Bootstrap Path (seed: {cfg.bootstrap}) ==="
    IO.println "  Priority order (by globality tier):"
    let tier1 := gaps.filter fun (d, _) => d == .energy || d == .water || d == .food || d == .shelter
    let tier2 := gaps.filter fun (d, _) => d == .medical || d == .comms || d == .compute
    let tier3 := gaps.filter fun (d, _) => d == .intelligence || d == .defense
    let tier4 := gaps.filter fun (d, _) => d == .transport || d == .trade || d == .fabrication
    for (label, tier) in [("Tier 1 (critical)", tier1), ("Tier 2 (essential)", tier2),
        ("Tier 3 (operational)", tier3), ("Tier 4 (expansion)", tier4)] do
      if !tier.isEmpty then do
        IO.println s!"  {label}:"
        for (d, c) in tier do
          IO.println s!"    - {d}/{c}"
  | .validate => do
    let errs := validateAll cfg
    if errs.isEmpty then
      IO.println "=== Validation: ALL CLEAR ==="
    else do
      IO.println s!"=== Validation: {errs.length} issues ==="
      for e in errs do
        IO.println s!"  ! {e}"
  | .pack mode => do
    let (items, errs) := packItems cfg mode
    IO.println s!"=== Pack: {mode} mode ==="
    IO.println s!"  Items: {items.length} | Weight: {totalWeight items}g | Volume: {totalVolume items}L"
    if !errs.isEmpty then do
      IO.println "  Constraint violations:"
      for e in errs do
        IO.println s!"    ! {e}"
    printItems s!"Pack list ({mode})" items
  | .discover d => do
    let ditems := cfg.domainItems.find? (fun (did, _) => did == d)
    match ditems with
    | some (_, items) =>
      IO.println s!"=== Discover: {d} ==="
      IO.println s!"  Current items: {items.length}"
      let gaps := (gapDomains cfg).filter (fun (did, _) => did == d)
      IO.println s!"  Uncovered capabilities: {gaps.length}"
      for (_, c) in gaps do
        IO.println s!"    - {c}"
    | none => IO.println s!"Unknown domain: {d}"
