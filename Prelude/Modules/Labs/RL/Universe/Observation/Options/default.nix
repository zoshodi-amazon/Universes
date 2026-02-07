# Observation Options - state space preprocessing
{ lib, ... }:
{
  options.rl.observation = {
    normalize = lib.mkOption { type = lib.types.enum [ "none" "running" "fixed" ]; default = "none"; };
    clipRange = lib.mkOption { type = lib.types.str; default = "10.0"; };
    stackFrames = lib.mkOption { type = lib.types.nullOr lib.types.int; default = null; };
  };
}
