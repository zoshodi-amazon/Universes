-- Types/IO/Default.lean
-- [QGP] IO — Entry point and validation runner.
-- This is the Lake project root. lakefile.lean and lean-toolchain live here.
-- Terminal in the import DAG: may reference all lower layers.
-- Migrated from: Modules/Types/Default.lean

import Lean.Data.Json
import Types.Hom.Identity.Default
import Types.Hom.Platform.Default
import Types.Hom.Network.Default
import Types.Hom.Services.Default
import Types.Hom.User.Default
import Types.Hom.Workspace.Default
import Types.Hom.Deploy.Default

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
  let dir := args.head? |>.getD "."
  IO.println s!"Validating phase configs in {dir}"
  let mut ok := true
  ok := (← validateJson "Identity"  s!"{dir}/IOIdentityPhase/default.json"  IdentityHom) && ok
  ok := (← validateJson "Platform"  s!"{dir}/IOPlatformPhase/default.json"  PlatformHom) && ok
  ok := (← validateJson "Network"   s!"{dir}/IONetworkPhase/default.json"   NetworkHom) && ok
  ok := (← validateJson "Services"  s!"{dir}/IOServicesPhase/default.json"  ServicesHom) && ok
  ok := (← validateJson "Workspace" s!"{dir}/IOWorkspacePhase/default.json" WorkspaceHom) && ok
  if ok then IO.println "All phases valid"; return 0
  else IO.eprintln "Validation failed"; return 1
