# Python checks plugins
{ config, lib, ... }:
let cfg = config.checks.python; in
{
  config.checks.python.plugins = lib.mkIf cfg.enable {
    ruff = cfg.ruff.enable;
    black = cfg.black.enable;
    mypy = cfg.mypy.enable;
  };
}
