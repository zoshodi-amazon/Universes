# Containers Bindings - dispatch on backend
{ config, lib, ... }:
let
  cfg = config.servers.containers;

  containerDefs = lib.mapAttrs (_: stack: {
    inherit (stack) image;
    ports = stack.ports;
    volumes = stack.volumes;
    environment = stack.environment;
    autoStart = stack.autoStart;
  }) cfg.stacks;
in
{
  # Enable by default (module exists = capability desired)
  config.servers.containers.enable = lib.mkDefault true;
}
