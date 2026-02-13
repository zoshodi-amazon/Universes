-- MLeanSovereignty — pure queries over the sovereignty type space
-- Every function here is a pure fold: Sovereignty -> result (no IO)
import Sovereignty.Types

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
