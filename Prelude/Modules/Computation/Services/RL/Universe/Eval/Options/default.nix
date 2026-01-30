# Eval Options - evaluation configuration
{ lib, ... }:
{
  options.rl.eval = {
    episodes = lib.mkOption { type = lib.types.int; default = 10; };
    deterministic = lib.mkOption { type = lib.types.bool; default = true; };
    render = lib.mkOption { type = lib.types.bool; default = false; };
  };
}
