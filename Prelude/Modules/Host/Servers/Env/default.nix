# Env: aggregates Universe/*/Options -> ENV vars
{ config, lib, ... }:
let
  containers = config.servers.containers;
  objectStore = config.servers.data.objectStore;
in
{
  options.servers.env = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
  };

  config.servers.env = lib.optionalAttrs containers.enable {
    SERVERS_CONTAINERS_ENABLED = "true";
    SERVERS_CONTAINERS_BACKEND = containers.backend;
  } // lib.optionalAttrs objectStore.enable {
    SERVERS_OBJECTSTORE_ENABLED = "true";
    SERVERS_OBJECTSTORE_ENDPOINT = "http://localhost:${toString objectStore.port}";
  };
}
