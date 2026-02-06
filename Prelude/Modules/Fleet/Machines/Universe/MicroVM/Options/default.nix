{ lib, ... }:
{
  options.microvm-config = {
    mem = lib.mkOption {
      type = lib.types.int;
      default = 2048;
      description = "Memory in MB";
    };
    vcpu = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Virtual CPUs";
    };
    hypervisor = lib.mkOption {
      type = lib.types.enum [ "qemu" "cloud-hypervisor" "firecracker" ];
      default = "qemu";
      description = "Hypervisor backend";
    };
  };
}
