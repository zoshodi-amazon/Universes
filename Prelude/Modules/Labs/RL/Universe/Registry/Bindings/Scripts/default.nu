#!/usr/bin/env nu
# Registry binding: RegistrySpec -> Table
# SQLite model registry — list, validate, best, prune
# Delegates heavy operations to `rl registry` CLI

def main [config_path: string]: nothing -> nothing {
  let cfg: record = (open $config_path)
  print (gum style --border normal --padding "0 1" "RL Model Registry")
  (^rl registry list --db $cfg.registry.dbPath)
}

def "main list" [config_path: string]: nothing -> nothing {
  let cfg: record = (open $config_path)
  (^rl registry list --db $cfg.registry.dbPath)
}

def "main validated" [config_path: string]: nothing -> nothing {
  let cfg: record = (open $config_path)
  (^rl registry list --db $cfg.registry.dbPath --validated)
}

def "main best" [config_path: string]: nothing -> nothing {
  let cfg: record = (open $config_path)
  (^rl registry best --db $cfg.registry.dbPath)
}

def "main validate" [config_path: string, model_id: int]: nothing -> nothing {
  let cfg: record = (open $config_path)
  (^rl registry validate --db $cfg.registry.dbPath --id $model_id --min-reward $cfg.registry.minReward --min-episodes $cfg.registry.minEpisodes)
}

def "main prune" [config_path: string]: nothing -> nothing {
  let cfg: record = (open $config_path)
  (^rl registry prune --db $cfg.registry.dbPath --keep-top-n $cfg.registry.keepTopN --max-age $cfg.registry.maxAge)
}
