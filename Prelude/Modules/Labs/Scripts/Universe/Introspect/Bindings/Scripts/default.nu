#!/usr/bin/env nu

# Introspect module structure - features or options
# Usage: default.nu <json_config>
# Config: { mode: "features" | "options", module: "<path>" }

def main [config_json: string] {
  let cfg = ($config_json | from json)
  let module_dir = $cfg.module
  let universe_path = $"($module_dir)/Universe"
  
  if not ($universe_path | path exists) {
    print $"No Universe/ in ($module_dir)"
    exit 1
  }
  
  match $cfg.mode {
    "features" => {
      print $"Features in ($module_dir)/Universe/:"
      for feature in (ls $universe_path | where type == dir | get name) {
        let name = ($feature | path basename)
        print $"  ($name)"
      }
    }
    "options" => {
      print $"Options in ($module_dir):"
      print ""
      for feature in (ls $universe_path | where type == dir | get name) {
        let name = ($feature | path basename)
        let opts_file = $"($feature)/Options/default.nix"
        print $"[($name)]"
        if ($opts_file | path exists) {
          let lines = (open $opts_file | lines | where {|l| $l =~ "options\\." or $l =~ "= lib.mk"})
          if ($lines | is-empty) {
            print "  (no options found)"
          } else {
            for line in $lines {
              print $"  ($line | str trim)"
            }
          }
        } else {
          print "  (no Options/default.nix)"
        }
        print ""
      }
    }
  }
}
