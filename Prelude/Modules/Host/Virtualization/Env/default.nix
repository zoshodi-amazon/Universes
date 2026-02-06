# Env: aggregates Universe/*/Options → ENV vars
{ config, lib, ... }:
let cfg = config.virtualization.microvm; in
{
  options.virtualization.env = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
  config.virtualization.env = lib.mkIf cfg.enable {
    MICROVM_ENABLED = lib.boolToString cfg.enable;
  };
}
