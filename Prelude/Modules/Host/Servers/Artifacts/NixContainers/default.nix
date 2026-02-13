# NixContainers Artifact — typed option space for container orchestration
{ lib, ... }:
{
  options.servers.containers = {
    enable = lib.mkEnableOption "Container orchestration";
    backend = lib.mkOption {
      type = lib.types.enum [ "podman" "arion" ];
      default = "podman";
      description = "Container orchestration backend";
    };
    stacks = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          image = lib.mkOption { type = lib.types.str; description = "Container image"; };
          ports = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
          volumes = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
          environment = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
          autoStart = lib.mkOption { type = lib.types.bool; default = true; };
        };
      });
      default = {};
      description = "Container stack definitions";
    };
  };
}