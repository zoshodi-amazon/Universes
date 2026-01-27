#!/usr/bin/env nu
# Invariant 5: Bindings/ ⊆ {Scripts, Commands, Keymaps, Hooks, State, Secrets, Plugins}

let allowed = ["Scripts" "Commands" "Keymaps" "Hooks" "State" "Secrets" "Plugins"]
let modules_root = $env.MODULES_ROOT? | default "Modules"

# Find all Bindings dirs
let bindings_dirs = (glob $"($modules_root)/**/Bindings")

let violations = ($bindings_dirs | each { |bd|
  let subdirs = (ls $bd | where type == dir | get name | each { $in | path basename })
  let invalid = ($subdirs | where { $in not-in $allowed })
  if ($invalid | length) > 0 {
    { bindings: $bd, invalid: $invalid }
  }
} | compact)

if ($violations | length) > 0 {
  print "❌ Invariant 5 violations:"
  $violations | each { |v| print $"  ($v.bindings): invalid subdirs ($v.invalid | str join ', ')" }
  exit 1
}

print $"✓ Invariant 5: All Bindings/ subdirs are valid"
