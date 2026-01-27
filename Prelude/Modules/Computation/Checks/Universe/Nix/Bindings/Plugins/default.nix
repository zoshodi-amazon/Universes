# Nix checks plugins (tools)
{ config, lib, ... }:
let cfg = config.checks.nix; in
{
  config.checks.nix.plugins = lib.mkIf cfg.enable {
    nixfmt = cfg.nixfmt.enable;
    deadnix = cfg.deadnix.enable;
    statix = cfg.statix.enable;
  };
}
