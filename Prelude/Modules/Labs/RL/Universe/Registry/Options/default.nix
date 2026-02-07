# Registry Options - model metadata, validation, hotswap
{ lib, ... }:
{
  options.rl.registry = {
    enable = lib.mkOption { type = lib.types.bool; default = true; };
    dbPath = lib.mkOption { type = lib.types.str; default = "./rl.db"; };
    minReward = lib.mkOption { type = lib.types.str; default = "0"; };
    minEpisodes = lib.mkOption { type = lib.types.int; default = 5; };
    keepTopN = lib.mkOption { type = lib.types.int; default = 10; };
    maxAge = lib.mkOption { type = lib.types.int; default = 30; };
  };
}
