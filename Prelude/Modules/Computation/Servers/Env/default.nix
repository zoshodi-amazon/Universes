# Env: aggregates Universe/*/Options → ENV vars
{ config, lib, ... }:
let 
  podman = config.servers.podman;
  objectStore = config.servers.data.objectStore;
in
{
  options.servers.env = lib.mkOption { 
    type = lib.types.attrsOf lib.types.str; 
    default = {}; 
  };
  
  config.servers.env = {
    SERVERS_PODMAN_ENABLED = lib.boolToString podman.enable;
  } // lib.optionalAttrs objectStore.enable {
    SERVERS_OBJECTSTORE_ENABLED = "true";
    SERVERS_OBJECTSTORE_ENDPOINT = "http://localhost:${toString objectStore.port}";
  };
}
