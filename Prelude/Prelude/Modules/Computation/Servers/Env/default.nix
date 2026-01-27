# Env: aggregates Universe/*/Options → ENV vars
{ config, lib, ... }:
let cfg = config.servers.podman; in
{
  options.servers.env = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
  config.servers.env = lib.mkIf cfg.enable {
    PODMAN_ENABLED = lib.boolToString cfg.enable;
  };
}
