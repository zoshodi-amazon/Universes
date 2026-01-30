# Obs Options - observation space
{ lib, ... }:
{
  options.rl.obs = {
    normalize = lib.mkOption { type = lib.types.bool; default = true; };
    clipRange = lib.mkOption { type = lib.types.nullOr lib.types.float; default = 10.0; };
    stackFrames = lib.mkOption { type = lib.types.nullOr lib.types.int; default = null; };
  };
}
