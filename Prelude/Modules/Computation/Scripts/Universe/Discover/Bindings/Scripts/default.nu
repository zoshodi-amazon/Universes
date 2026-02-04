#!/usr/bin/env nu

# List all modules in the system
# Usage: default.nu

def main [] {
  print "Modules/"
  for category in (ls Modules/ | where type == dir | get name) {
    let cat_name = ($category | path basename)
    print $"  ($cat_name)/"
    for module in (ls $category | where type == dir | get name) {
      let mod_name = ($module | path basename)
      print $"    ($mod_name)/"
    }
  }
}
