# Arion Options - docker-compose in Nix
{ lib, ... }:
{
  options.servers.arion = {
    enable = lib.mkEnableOption "Arion docker-compose";
    projects = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = {};
      description = "Arion project definitions";
    };
  };
}
