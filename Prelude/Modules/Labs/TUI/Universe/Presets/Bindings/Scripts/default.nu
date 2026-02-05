#!/usr/bin/env nu
# Presets - Zoo hierarchy management
# Strongly typed throughout

def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)
  let action: string = ($cfg.action? | default "list")

  match $action {
    "list" => { list_presets }
    "save" => { save_preset $cfg.name $cfg.knobs }
    "load" => { load_preset $cfg.name }
    _ => { print $"Unknown action: ($action)" }
  }
}

def list_presets []: nothing -> nothing {
  print (gum style --border normal --padding "0 1" "Presets (Zoo)")
  
  # Global
  print "  Global:"
  let global_path: string = "Universe/Presets/global/"
  if ($global_path | path exists) {
    for f in (ls $global_path | get name) { print $"    - ($f | path basename)" }
  } else {
    print "    (none)"
  }
  
  # User
  print "  User:"
  let user_path: string = ".lab/presets/"
  if ($user_path | path exists) {
    for f in (ls $user_path | get name) { print $"    - ($f | path basename)" }
  } else {
    print "    (none)"
  }
}

def save_preset [name: string, knobs: record]: nothing -> nothing {
  let path: string = $".lab/presets/($name).json"
  let dir: string = ($path | path dirname)
  if not ($dir | path exists) { mkdir $dir }
  
  $knobs | to json | save -f $path
  print $"Saved preset: ($name)"
}

def load_preset [name: string]: nothing -> record {
  # Search hierarchy: user -> domain -> global
  let user_path: string = $".lab/presets/($name).json"
  if ($user_path | path exists) {
    return (open $user_path)
  }
  
  let global_path: string = $"Universe/Presets/global/($name).json"
  if ($global_path | path exists) {
    return (open $global_path)
  }
  
  print $"Preset not found: ($name)"
  {}
}
