#!/usr/bin/env nu
# Library - Asset persistence with full history
# Interprets lab.library Options
# All types explicit - no implicit conversions

def empty_db []: nothing -> record {
  { assets: [], history: [] }
}

def load_db [path: string]: nothing -> record {
  if ($path | path exists) {
    open $path
  } else {
    empty_db
  }
}

def save_db [path: string, db: record]: nothing -> nothing {
  let dir = ($path | path dirname)
  if not ($dir | path exists) { mkdir $dir }
  $db | to json | save -f $path
}

def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)
  let db_path: string = ($cfg.db_path? | default ".lab/library.json")
  let action: string = ($cfg.action? | default "list")

  match $action {
    "init" => {
      save_db $db_path (empty_db)
      print $"Initialized library: ($db_path)"
    }
    "add" => {
      let db: record = (load_db $db_path)
      let id: string = ($cfg.id? | default (random uuid))
      let now: string = (date now | format date "%Y-%m-%dT%H:%M:%S")
      
      let asset: record = {
        id: $id
        name: ($cfg.name | into string)
        path: ($cfg.path | into string)
        source: ($cfg.source? | default "file" | into string)
        tags: ($cfg.tags? | default [])
        created: $now
      }
      
      let history_entry: record = {
        assetId: $id
        action: "create"
        timestamp: $now
        state: $asset
      }
      
      let new_db: record = {
        assets: ($db.assets | append $asset)
        history: ($db.history | append $history_entry)
      }
      
      save_db $db_path $new_db
      print $"Added asset: ($cfg.name) [($id)]"
    }
    "list" => {
      let db: record = (load_db $db_path)
      print ($db.assets | table)
    }
    "get" => {
      let db: record = (load_db $db_path)
      let id: string = $cfg.id
      print ($db.assets | where id == $id | first | table)
    }
    "history" => {
      let db: record = (load_db $db_path)
      print ($db.history | sort-by timestamp --reverse | table)
    }
    _ => { print $"Unknown action: ($action)" }
  }
}
