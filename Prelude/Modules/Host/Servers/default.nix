# Servers — global instantiation
{ config, lib, inputs, ... }:
let
  containers = config.servers.containers;
  containerDefs = lib.mapAttrs (_: stack: {
    inherit (stack) image;
    ports = stack.ports;
    volumes = stack.volumes;
    environment = stack.environment;
    autoStart = stack.autoStart;
  }) containers.stacks;
in
{
  config.flake.modules.nixos.servers = lib.mkIf containers.enable (
    if containers.backend == "podman" then {
      virtualisation.podman.enable = true;
      virtualisation.oci-containers.backend = "podman";
      virtualisation.oci-containers.containers = containerDefs;
    }
    else if containers.backend == "arion" then {
      virtualisation.podman.enable = true;
      virtualisation.arion.projects = lib.mapAttrs (_: stack: {
        settings.services.${stack.image} = {
          service.image = stack.image;
          service.ports = stack.ports;
          service.volumes = stack.volumes;
          service.environment = stack.environment;
        };
      }) containers.stacks;
    }
    else {}
  );
}