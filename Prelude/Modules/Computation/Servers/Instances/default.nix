# Servers Instances - exports to flake.modules.nixos only
# Servers are capabilities consumed by Machines, not deployed directly
{ config, lib, ... }:
let
  podman = config.servers.podman;
  
  containerDefs = lib.mapAttrs (name: stack: {
    inherit (stack) image;
    ports = stack.ports;
    volumes = stack.volumes;
    environment = stack.environment;
    autoStart = stack.autoStart;
  }) podman.stacks;
in
{
  config.flake.modules.nixos.servers = lib.mkIf podman.enable {
    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers = containerDefs;
  };
}
