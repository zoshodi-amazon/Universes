# Instances: exports to BOTH flake.modules.homeManager AND flake.modules.nixos
# Containers are portable (invariant 22)
{ config, lib, inputs, ... }:
let
  podman = config.servers.podman;
  
  # Shared podman container definitions
  containerDefs = lib.mapAttrs (name: stack: {
    inherit (stack) image;
    ports = stack.ports;
    volumes = stack.volumes;
    environment = stack.environment;
    autoStart = stack.autoStart;
  }) podman.stacks;
in
{
  # Export to homeManager (portable - Darwin, NixOS, anywhere)
  config.flake.modules.homeManager.servers = lib.mkIf podman.enable {
    # home-manager podman integration
    services.podman = {
      enable = true;
      containers = containerDefs;
    };
  };

  # Export to nixos (system-level integration when needed)
  config.flake.modules.nixos.servers = lib.mkIf podman.enable {
    virtualisation.podman.enable = true;
    virtualisation.oci-containers.backend = "podman";
    virtualisation.oci-containers.containers = containerDefs;
  };
}
