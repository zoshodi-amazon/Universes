#!/usr/bin/env nu
# Metrics - Artifact measurement and comparison
# Strongly typed throughout

def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)
  let db_path: string = ($cfg.db_path? | default ".lab/library.db")
  let action: string = ($cfg.action? | default "summary")

  match $action {
    "summary" => { show_summary $db_path }
    "compare" => { compare_artifacts $db_path $cfg.baseline $cfg.target }
    _ => { print $"Unknown action: ($action)" }
  }
}

def show_summary [db_path: string]: nothing -> nothing {
  if not ($db_path | path exists) {
    print "No database found"
    return
  }
  
  let db: record = (open $db_path)
  let assets: table = ($db | get assets)
  let count: int = ($assets | length)
  
  print (gum style --border normal --padding "0 1" "Metrics Summary")
  print $"  Total artifacts: ($count)"
  print $"  Database: ($db_path)"
}

def compare_artifacts [db_path: string, baseline: string, target: string]: nothing -> nothing {
  let db: record = (open $db_path)
  let assets: table = ($db | get assets)
  
  let base: record = ($assets | where id == $baseline | first)
  let tgt: record = ($assets | where id == $target | first)
  
  print (gum style --border normal --padding "0 1" "Comparison")
  print $"  Baseline: ($base.name)"
  print $"  Target: ($tgt.name)"
}
