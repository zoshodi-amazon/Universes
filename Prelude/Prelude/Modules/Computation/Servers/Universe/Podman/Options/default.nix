# Podman Options
{ lib, ... }:
{
  options.servers.podman = {
    enable = lib.mkEnableOption "Podman container stacks";
    stacks = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          image = lib.mkOption { type = lib.types.str; };
          ports = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
          volumes = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
          environment = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
          autoStart = lib.mkOption { type = lib.types.bool; default = true; };
        };
      });
      default = {};
    };
  };
}
