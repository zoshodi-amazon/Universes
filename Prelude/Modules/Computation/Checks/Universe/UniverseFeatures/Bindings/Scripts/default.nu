#!/usr/bin/env nu
# Invariant 3: Every Universe/<Feature> has Options/, Bindings/
# Features can be nested - only check leaf features (those without sub-features)

let required = ["Options" "Bindings"]
let modules_root = $env.MODULES_ROOT? | default "Modules"

# Find all Universe dirs, then get their feature subdirs
let all_features = (glob $"($modules_root)/**/Universe/*" 
  | where { $in | path type | $in == "dir" }
  | where { ($in | path basename) != "default.nix" })

# A feature is a leaf if it has no subdirs that are also features (i.e., no nested Universe structure)
# Leaf = has Options or Bindings, OR has no subdirs that themselves have Options/Bindings
let leaf_features = ($all_features | where { |feat|
  let has_options_or_bindings = (($feat | path join "Options" | path exists) or ($feat | path join "Bindings" | path exists))
  let subdirs = (ls $feat | where type == "dir" | get name | where { ($in | path basename) not-in ["Options" "Bindings"] })
  let has_nested_features = ($subdirs | any { |sub| ($sub | path join "Options" | path exists) or ($sub | path join "Bindings" | path exists) })
  $has_options_or_bindings or (not $has_nested_features)
})

let violations = ($leaf_features | each { |feat|
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

print $"✓ Invariant 3: All ($leaf_features | length) Universe leaf features have Options/ and Bindings/"
