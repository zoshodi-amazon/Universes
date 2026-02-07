# RL Options - root enable and internal wiring
{ lib, ... }:
{
  options.rl = {
    enable = lib.mkEnableOption "Reinforcement Learning pipeline";
    _internal.storeEnvVars = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
    _internal.dataEnvVars = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
    _internal.executionEnvVars = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
  };
}
