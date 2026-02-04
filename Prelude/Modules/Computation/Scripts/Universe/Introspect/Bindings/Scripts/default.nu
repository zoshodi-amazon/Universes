#!/usr/bin/env nu

# Introspect Nix module options - list all features and their options
# Usage: default.nu [module_dir]

def main [module_dir: string = "Modules/Computation/Services/RL"] {
  print $"📋 Features in ($module_dir)/Universe/\n"
  
  let features = (
    ls $"($module_dir)/Universe" 
    | where type == dir 
    | get name 
    | path basename
  )
  
  for feature in $features {
    print $"\n🔹 ($feature)"
    
    let options_file = $"($module_dir)/Universe/($feature)/Options/default.nix"
    
    if ($options_file | path exists) {
      let lines = (open $options_file | lines)
      
      for line in $lines {
        if ($line | str contains "options.") and ($line | str contains "=") {
          let trimmed = ($line | str trim)
          # Extract just the option name after the last dot
          let parts = ($trimmed | split row ".")
          if ($parts | length) > 2 {
            let option_part = ($parts | last | split row " " | first | str trim)
            print $"    • ($option_part)"
          }
        }
      }
    } else {
      print "    (no options file)"
    }
  }
}
