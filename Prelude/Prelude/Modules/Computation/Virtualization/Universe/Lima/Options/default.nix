# Lima Options - Linux VMs on macOS
{ lib, ... }:
{
  options.virtualization.lima = {
    enable = lib.mkEnableOption "Lima Linux VMs";
    vmType = lib.mkOption {
      type = lib.types.enum [ "vz" "qemu" ];
      default = "vz";
      description = "Virtualization framework (vz = Apple Virtualization, qemu)";
    };
    cpus = lib.mkOption {
      type = lib.types.int;
      default = 4;
    };
    memory = lib.mkOption {
      type = lib.types.str;
      default = "8GiB";
    };
    disk = lib.mkOption {
      type = lib.types.str;
      default = "100GiB";
    };
    mountHome = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Mount home directory into VM";
    };
  };
  config.virtualization.lima.enable = lib.mkDefault true;
}
