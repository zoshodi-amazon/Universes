import Lean.Data.Json
import PhaseInputTypes.IdentityInput.Default
import PhaseInputTypes.PlatformInput.Default
import PhaseInputTypes.NetworkInput.Default
import PhaseInputTypes.ServicesInput.Default
import PhaseInputTypes.UserInput.Default
import PhaseInputTypes.WorkspaceInput.Default
import PhaseInputTypes.DeployInput.Default

open Lean (Json FromJson fromJson?)

def validateJson (name : String) (path : System.FilePath) (α : Type) [FromJson α] : IO Bool := do
  let contents ← IO.FS.readFile path
  match Json.parse contents with
  | .error e => IO.eprintln s!"[FAIL] {name}: JSON parse error: {e}"; return false
  | .ok json =>
    match @fromJson? α _ json with
    | .error e => IO.eprintln s!"[FAIL] {name}: schema mismatch: {e}"; return false
    | .ok _ => IO.println s!"[ OK ] {name}"; return true

def main (args : List String) : IO UInt32 := do
  let dir := args.head? |>.getD "../Monads"
  IO.println s!"Validating phase configs in {dir}"
  let mut ok := true
  ok := (← validateJson "Identity"  s!"{dir}/IOIdentityPhase/default.json"  IdentityInput) && ok
  ok := (← validateJson "Platform"  s!"{dir}/IOPlatformPhase/default.json"  PlatformInput) && ok
  ok := (← validateJson "Network"   s!"{dir}/IONetworkPhase/default.json"   NetworkInput) && ok
  ok := (← validateJson "Services"  s!"{dir}/IOServicesPhase/default.json"  ServicesInput) && ok
  ok := (← validateJson "Workspace" s!"{dir}/IOWorkspacePhase/default.json" WorkspaceInput) && ok
  if ok then IO.println "All phases valid"; return 0
  else IO.eprintln "Validation failed"; return 1
