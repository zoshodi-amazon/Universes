# Env: aggregates Universe/*/Options → ENV vars
{ config, lib, ... }:
let cfg = config.ssh; in
{
  options.ssh.env = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
  config.ssh.env = lib.mkIf cfg.enable {
    SSH_DEFAULT_PORT = toString cfg.defaultPort;
    SSH_COMPRESSION = lib.boolToString cfg.compression;
    SSH_SERVER_ALIVE_INTERVAL = toString cfg.serverAliveInterval;
    SSH_SERVER_ALIVE_COUNT_MAX = toString cfg.serverAliveCountMax;
    SSH_FORWARD_AGENT = lib.boolToString cfg.forwardAgent;
  };
}
