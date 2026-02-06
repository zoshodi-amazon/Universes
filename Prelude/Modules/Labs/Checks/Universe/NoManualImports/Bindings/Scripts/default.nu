#!/usr/bin/env nu
# Invariant 11: NO manual imports - all default.nix files are { ... }: { }

let modules_root = $env.MODULES_ROOT? | default "Modules"

# Find all .nix files with "imports = ["
let violations = (glob $"($modules_root)/**/*.nix" 
  | each { |f|
    let content = (open $f --raw)
    if ($content | str contains "imports = [") {
      # Allow Instances files that import external modules (e.g., nixvim)
      if not ($f | str ends-with "Instances/default.nix") {
        $f
      }
    }
  } 
  | compact)

if ($violations | length) > 0 {
  print "❌ Invariant 11 violations (manual imports found):"
  $violations | each { |v| print $"  ($v)" }
  exit 1
}

print "✓ Invariant 11: No manual imports found"
