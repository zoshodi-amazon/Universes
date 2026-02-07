#!/usr/bin/env nu
# Eval binding: EvalSpec -> Effect
# Typed off Nix module Options — config shape = Options type

def main [config_path: string]: nothing -> nothing {
  let cfg: record = (open $config_path)
  let best: string = (^rl registry best --db $cfg.registry.dbPath)

  (^rl eval
    --model $best
    --episodes $cfg.eval.episodes
    --db $cfg.registry.dbPath)
}
