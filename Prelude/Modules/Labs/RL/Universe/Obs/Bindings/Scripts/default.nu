#!/usr/bin/env nu
# Obs binding: ObsSpec → Table
# Looking glass into runtime (logs) + persistent (SQLite) data
# Native nushell SQLite interop — no external tools needed

def main [config_path: string]: nothing -> nothing {
  let cfg: record = (open $config_path)
  let db_path: string = $cfg.obs.dbPath

  print (gum style --border normal --padding "0 1" "RL Registry")

  open $db_path
    | query db "SELECT id, env_id, algorithm, timesteps, mean_reward, std_reward, validated, model_path FROM runs ORDER BY mean_reward DESC"
    | table
    | print
}

# List only validated models
def "main validated" [config_path: string]: nothing -> nothing {
  let cfg: record = (open $config_path)

  open $cfg.obs.dbPath
    | query db "SELECT id, env_id, algorithm, mean_reward, model_path FROM runs WHERE validated=1 ORDER BY mean_reward DESC"
    | table
    | print
}

# Show latest N runs
def "main latest" [config_path: string, n: int = 10]: nothing -> nothing {
  let cfg: record = (open $config_path)

  open $cfg.obs.dbPath
    | query db $"SELECT id, env_id, algorithm, timesteps, mean_reward, validated FROM runs ORDER BY timestamp DESC LIMIT ($n)"
    | table
    | print
}
