#!/usr/bin/env nu
# Library - SQLite asset persistence with full history
# Interprets lab.library Options
# Strongly typed - all annotations explicit

def main [config_json: string]: nothing -> nothing {
  let cfg: record = ($config_json | from json)
  let db_path: string = ($cfg.db_path? | default ".lab/library.db")
  let action: string = ($cfg.action? | default "list")

  match $action {
    "init" => { init_db $db_path }
    "add" => { add_asset $db_path $cfg }
    "list" => { list_assets $db_path }
    "get" => { get_asset $db_path $cfg.id }
    "history" => { get_history $db_path }
    _ => { print $"Unknown action: ($action)" }
  }
}

def init_db [db_path: string]: nothing -> nothing {
  let dir: string = ($db_path | path dirname)
  if not ($dir | path exists) { mkdir $dir }
  
  stor reset
  stor create --table-name assets --columns {id: str, name: str, path: str, source: str, tags: str, created: str}
  stor create --table-name history --columns {id: int, asset_id: str, action: str, state: str, timestamp: str}
  stor export --file-name $db_path
  print $"Initialized library: ($db_path)"
}

def add_asset [db_path: string, cfg: record]: nothing -> nothing {
  # Load existing data
  let db: record = (load_db $db_path)
  
  let id: string = ($cfg.id? | default (random uuid))
  let now: string = (date now | format date "%Y-%m-%dT%H:%M:%S")
  let name: string = ($cfg.name | into string)
  let path: string = ($cfg.path | into string)
  let source: string = ($cfg.source? | default "file" | into string)
  let tags: string = ($cfg.tags? | default [] | to json -r)
  
  stor reset
  stor create --table-name assets --columns {id: str, name: str, path: str, source: str, tags: str, created: str}
  stor create --table-name history --columns {id: int, asset_id: str, action: str, state: str, timestamp: str}
  
  # Re-insert existing
  for row: record in $db.assets { stor insert --table-name assets --data-record $row }
  for row: record in $db.history { stor insert --table-name history --data-record $row }
  
  # Insert new asset
  stor insert --table-name assets --data-record {
    id: $id, name: $name, path: $path, source: $source, tags: $tags, created: $now
  }
  
  # Insert history
  let state: string = ({name: $name, path: $path, source: $source} | to json -r)
  let hist_id: int = (($db.history | length) + 1)
  stor insert --table-name history --data-record {
    id: $hist_id, asset_id: $id, action: "create", state: $state, timestamp: $now
  }
  
  stor export --file-name $db_path
  print $"Added asset: ($name) [($id)]"
}

def list_assets [db_path: string]: nothing -> nothing {
  let db: record = (load_db $db_path)
  print ($db.assets | table)
}

def get_asset [db_path: string, id: string]: nothing -> nothing {
  let db: record = (load_db $db_path)
  let matches: table = ($db.assets | where id == $id)
  if ($matches | is-empty) {
    print $"Asset not found: ($id)"
  } else {
    print ($matches | first | table)
  }
}

def get_history [db_path: string]: nothing -> nothing {
  let db: record = (load_db $db_path)
  print ($db.history | sort-by timestamp --reverse | table)
}

def load_db [db_path: string]: nothing -> record {
  if not ($db_path | path exists) {
    { assets: [], history: [] }
  } else {
    let db = (open $db_path)
    { assets: ($db | get assets), history: ($db | get history) }
  }
}
