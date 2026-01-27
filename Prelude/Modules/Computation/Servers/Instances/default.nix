# Instances: exports to flake.modules.nixos for podman and arion
{ config, lib, inputs, ... }:
let
  podman = config.servers.podman;
  arion = config.servers.arion;
in
{
  config.flake.modules.nixos.podman = lib.mkIf podman.enable {
    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers = lib.mapAttrs (name: stack: {
      inherit (stack) image;
      ports = stack.ports;
      volumes = stack.volumes;
      environment = stack.environment;
      autoStart = stack.autoStart;
    }) podman.stacks;
  };

  config.flake.modules.nixos.arion = lib.mkIf arion.enable {
    imports = [ inputs.arion.nixosModules.arion ];
    virtualisation.arion.projects = arion.projects;
  };
}
