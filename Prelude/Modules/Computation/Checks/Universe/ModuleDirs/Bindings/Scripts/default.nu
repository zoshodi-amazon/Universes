#!/usr/bin/env nu
# Invariant 2: Every Module has README.md, default.nix, Env/, Instances/, Universe/

let required = ["README.md" "default.nix" "Env" "Instances" "Universe"]
let modules_root = $env.MODULES_ROOT? | default "Modules"

# Find all Module dirs (dirs containing Universe/)
let modules = (glob $"($modules_root)/**/Universe" | each { $in | path dirname })

let violations = ($modules | each { |mod|
  let missing = ($required | where { |r| not ($mod | path join $r | path exists) })
  if ($missing | length) > 0 {
    { module: $mod, missing: $missing }
  }
} | compact)

if ($violations | length) > 0 {
  print "❌ Invariant 2 violations:"
  $violations | each { |v| print $"  ($v.module): missing ($v.missing | str join ', ')" }
  exit 1
}

print $"✓ Invariant 2: All ($modules | length) modules have required structure"
