# Env Options - environment specification
{ lib, ... }:
{
  options.rl.env = {
    envId = lib.mkOption { type = lib.types.str; default = "CartPole-v1"; };
    nEnvs = lib.mkOption { type = lib.types.int; default = 4; };
    seed = lib.mkOption { type = lib.types.nullOr lib.types.int; default = null; };
    wrappers = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
    vars = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
  };
}
