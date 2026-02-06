#!/usr/bin/env nu
# Train binding: TrainSpec → Effect
# Typed off Nix module Options — config shape = Options type

def main [config_path: string]: nothing -> nothing {
  let cfg: record = (open $config_path)

  (^rl train
    --env $cfg.env.envId
    --algo $cfg.agent.algorithm
    --timesteps $cfg.train.totalTimesteps
    --lr $cfg.train.learningRate
    --db $cfg.obs.dbPath)
}
