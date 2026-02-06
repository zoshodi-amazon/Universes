#!/usr/bin/env nu
# Infer binding: InferSpec → Effect
# Typed off Nix module Options — config shape = Options type

def main [config_path: string]: nothing -> nothing {
  let cfg: record = (open $config_path)
  let best: string = (db_best_model $cfg.obs.dbPath)

  (^rl infer
    --model $best
    --device $cfg.infer.device)
}

# Query best validated model from SQLite
def db_best_model [db_path: string]: nothing -> string {
  let result = (open $db_path
    | query db "SELECT model_path FROM runs WHERE validated=1 ORDER BY mean_reward DESC LIMIT 1")
  if ($result | is-empty) {
    error make {msg: "No validated models found"}
  }
  $result.0.model_path
}
