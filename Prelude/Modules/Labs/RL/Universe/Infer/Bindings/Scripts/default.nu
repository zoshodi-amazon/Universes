#!/usr/bin/env nu
# Infer binding: InferSpec -> Effect
# Typed off Nix module Options — config shape = Options type

def main [config_path: string]: nothing -> nothing {
  let cfg: record = (open $config_path)
  let best: string = (^rl registry best --db $cfg.registry.dbPath)

  (^rl infer
    --model $best
    --device $cfg.infer.device)
}
