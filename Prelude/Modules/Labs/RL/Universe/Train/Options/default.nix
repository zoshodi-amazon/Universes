# Train Options - training configuration
{ lib, ... }:
{
  options.rl.train = {
    totalTimesteps = lib.mkOption { type = lib.types.int; default = 100000; };
    learningRate = lib.mkOption { type = lib.types.str; default = "3e-4"; };
    batchSize = lib.mkOption { type = lib.types.int; default = 64; };
    gamma = lib.mkOption { type = lib.types.str; default = "0.99"; };
    logDir = lib.mkOption { type = lib.types.str; default = "./logs"; };
  };
}
