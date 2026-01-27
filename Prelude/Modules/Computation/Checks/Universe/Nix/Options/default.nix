# Nix checks options
{ lib, ... }:
{
  options.checks.nix = {
    enable = lib.mkEnableOption "Nix linting";
    nixfmt.enable = lib.mkOption { type = lib.types.bool; default = true; };
    deadnix.enable = lib.mkOption { type = lib.types.bool; default = true; };
    statix.enable = lib.mkOption { type = lib.types.bool; default = true; };
    plugins = lib.mkOption { type = lib.types.attrsOf lib.types.bool; default = {}; };
  };
}
