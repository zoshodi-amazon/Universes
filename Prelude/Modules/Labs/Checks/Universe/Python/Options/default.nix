# Python checks options
{ lib, ... }:
{
  options.checks.python = {
    enable = lib.mkEnableOption "Python linting";
    ruff.enable = lib.mkOption { type = lib.types.bool; default = true; };
    black.enable = lib.mkOption { type = lib.types.bool; default = true; };
    mypy.enable = lib.mkOption { type = lib.types.bool; default = false; };
    plugins = lib.mkOption { type = lib.types.attrsOf lib.types.bool; default = {}; };
  };
}
