#!/usr/bin/env nu
# Invariant 3: Every Universe/<Feature> has Options/, Bindings/

let required = ["Options" "Bindings"]
let modules_root = $env.MODULES_ROOT? | default "Modules"

# Find all Universe dirs, then get their feature subdirs
let features = (glob $"($modules_root)/**/Universe/*" 
  | where { $in | path type | $in == "dir" }
  | where { ($in | path basename) != "default.nix" })

let violations = ($features | each { |feat|
  let missing = ($required | where { |r| not ($feat | path join $r | path exists) })
  if ($missing | length) > 0 {
    { feature: $feat, missing: $missing }
  }
} | compact)

if ($violations | length) > 0 {
  print "❌ Invariant 3 violations:"
  $violations | each { |v| print $"  ($v.feature): missing ($v.missing | str join ', ')" }
  exit 1
}

print $"✓ Invariant 3: All ($features | length) Universe features have Options/ and Bindings/"
