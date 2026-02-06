# MicroVM Options
{ lib, ... }:
{
  options.virtualization.microvm = {
    enable = lib.mkEnableOption "MicroVM testing VMs";
    vms = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          vcpu = lib.mkOption { type = lib.types.int; default = 2; };
          mem = lib.mkOption { type = lib.types.int; default = 512; };
          hypervisor = lib.mkOption { type = lib.types.enum [ "qemu" "cloud-hypervisor" "firecracker" ]; default = "qemu"; };
          shares = lib.mkOption { type = lib.types.listOf lib.types.attrs; default = []; };
          interfaces = lib.mkOption { type = lib.types.listOf lib.types.attrs; default = []; };
        };
      });
      default = {};
    };
  };
}
