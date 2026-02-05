#!/usr/bin/env nu
# Library - SQLite asset persistence with full history
# Interprets lab.library Options

def main [config_json: string] {
  let cfg = ($config_json | from json)
  let db = ($cfg.path? | default ".lab/library.db")
  let action = ($cfg.action? | default "list")

  match $action {
    "init" => { init_db $db }
    "add" => { add_asset $db $cfg }
    "list" => { list_assets $db }
    "get" => { get_asset $db $cfg.id }
    "history" => { get_history $db $cfg.id? }
    "undo" => { undo $db $cfg.id }
    "redo" => { redo $db $cfg.id }
    _ => { print $"Unknown action: ($action)" }
  }
}

def init_db [db: string] {
  let dir = ($db | path dirname)
  if not ($dir | path exists) { mkdir $dir }
  
  sqlite3 $db "
    CREATE TABLE IF NOT EXISTS assets (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      path TEXT NOT NULL,
      source TEXT NOT NULL,
      tags TEXT DEFAULT '[]',
      created TEXT DEFAULT (datetime('now'))
    );
    CREATE TABLE IF NOT EXISTS history (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      asset_id TEXT NOT NULL,
      timestamp TEXT DEFAULT (datetime('now')),
      action TEXT NOT NULL,
      state TEXT NOT NULL,
      FOREIGN KEY (asset_id) REFERENCES assets(id)
    );
    CREATE INDEX IF NOT EXISTS idx_history_asset ON history(asset_id);
  "
  print $"Initialized library: ($db)"
}

def add_asset [db: string, cfg: record] {
  let id = ($cfg.id? | default (random uuid))
  let name = $cfg.name
  let path = $cfg.path
  let source = ($cfg.source? | default "file")
  let tags = ($cfg.tags? | default [] | to json)
  
  sqlite3 $db $"INSERT INTO assets \(id, name, path, source, tags\) VALUES \('($id)', '($name)', '($path)', '($source)', '($tags)'\);"
  
  # Record in history
  let state = { name: $name, path: $path, source: $source, tags: $tags } | to json
  sqlite3 $db $"INSERT INTO history \(asset_id, action, state\) VALUES \('($id)', 'create', '($state)'\);"
  
  print $"Added asset: ($name) [($id)]"
  $id
}

def list_assets [db: string] {
  sqlite3 -json $db "SELECT id, name, path, source, created FROM assets ORDER BY created DESC;" | from json
}

def get_asset [db: string, id: string] {
  sqlite3 -json $db $"SELECT * FROM assets WHERE id = '($id)';" | from json | first
}

def get_history [db: string, id?: string] {
  if $id == null {
    sqlite3 -json $db "SELECT * FROM history ORDER BY timestamp DESC LIMIT 50;" | from json
  } else {
    sqlite3 -json $db $"SELECT * FROM history WHERE asset_id = '($id)' ORDER BY timestamp DESC;" | from json
  }
}

def undo [db: string, id: string] {
  # Get previous state from history
  let hist = (sqlite3 -json $db $"SELECT * FROM history WHERE asset_id = '($id)' ORDER BY timestamp DESC LIMIT 2;" | from json)
  if ($hist | length) < 2 {
    print "Nothing to undo"
    return
  }
  let prev = ($hist | get 1)
  let state = ($prev.state | from json)
  
  # Record undo action
  sqlite3 $db $"INSERT INTO history \(asset_id, action, state\) VALUES \('($id)', 'restore', '($prev.state)'\);"
  print $"Undone to: ($prev.timestamp)"
}

def redo [db: string, id: string] {
  print "Redo not yet implemented"
}
