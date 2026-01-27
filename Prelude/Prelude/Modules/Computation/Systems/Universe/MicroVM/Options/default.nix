# MicroVM Options
{ lib, ... }:
{
  options.nixosSystems.microvm = {
    enable = lib.mkEnableOption "MicroVM NixOS image";
    memory = lib.mkOption {
      type = lib.types.int;
      default = 1024;
      description = "Memory in MB";
    };
    vcpu = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Number of virtual CPUs";
    };
    modules = lib.mkOption {
      type = lib.types.listOf lib.types.deferredModule;
      default = [];
      description = "Additional NixOS modules to include";
    };
  };
  config.nixosSystems.microvm.enable = lib.mkDefault true;
}
