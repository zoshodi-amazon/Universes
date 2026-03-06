# IOServicesPhase — container orchestration + servers
{ config, lib, ... }:
let
  cfg = builtins.fromJSON (builtins.readFile ./default.json);
  containers = cfg.containers;
  containerDefs = lib.mapAttrs (_: stack: {
    inherit (stack) image; ports = stack.ports; volumes = stack.volumes;
    environment = stack.environment; autoStart = stack.autoStart;
  }) containers.stacks;
in
{
  config.flake.modules.nixos.servers = lib.mkIf containers.enable (
    if containers.backend == "podman" then {
      virtualisation.podman.enable = true;
      virtualisation.oci-containers.backend = "podman";
      virtualisation.oci-containers.containers = containerDefs;
    } else {}
  );
}
