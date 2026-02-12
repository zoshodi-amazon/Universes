import Sovereignty.Types
import Sovereignty.Config
import Sovereignty.Queries

def parseCommand (args : List String) : Option Command :=
  match args with
  | ["status"]    => some .status
  | ["gaps"]      => some .gaps
  | ["bom"]       => some .bom
  | ["cost"]      => some .cost
  | ["weight"]    => some .weight
  | ["signature"] => some .signature
  | ["training"]  => some .training
  | ["bootstrap"] => some .bootstrap
  | ["validate"]  => some .validate
  | ["pack", "nomadic"] => some (.pack .nomadic)
  | ["pack", "urban"]   => some (.pack .urban)
  | ["pack", "base"]    => some (.pack .base)
  | ["discover", "energy"]       => some (.discover .energy)
  | ["discover", "water"]        => some (.discover .water)
  | ["discover", "food"]         => some (.discover .food)
  | ["discover", "shelter"]      => some (.discover .shelter)
  | ["discover", "medical"]      => some (.discover .medical)
  | ["discover", "comms"]        => some (.discover .comms)
  | ["discover", "compute"]      => some (.discover .compute)
  | ["discover", "intelligence"] => some (.discover .intelligence)
  | ["discover", "defense"]      => some (.discover .defense)
  | ["discover", "transport"]    => some (.discover .transport)
  | ["discover", "trade"]        => some (.discover .trade)
  | ["discover", "fabrication"]  => some (.discover .fabrication)
  | _ => none

def usage : IO Unit := do
  IO.println "sov -- sovereignty capability manager"
  IO.println ""
  IO.println "Commands:"
  IO.println "  status     Capability coverage matrix"
  IO.println "  gaps       Capabilities with no items or untrained"
  IO.println "  bom        Bill of materials with totals"
  IO.println "  cost       Cost breakdown by domain"
  IO.println "  weight     Weight breakdown by domain"
  IO.println "  signature  OPSEC posture across all domains"
  IO.println "  training   Items/capabilities needing training"
  IO.println "  bootstrap  Dependency-ordered acquisition path"
  IO.println "  validate   Check all constraints, report errors"
  IO.println "  pack <nomadic|urban|base>     Filter by mode constraints"
  IO.println "  discover <domain>             Research tools for domain"

def main (args : List String) : IO Unit := do
  let configPath ← IO.getEnv "SOV_CONFIG_PATH"
  let cfg ← match configPath with
    | some path => loadConfig path
    | none      => pure default
  match parseCommand args with
  | some cmd => dispatch cfg cmd
  | none     => usage
