{ lib, ... }:
{
  options.boot-config = {
    enable = lib.mkEnableOption "boot configuration";
    loader = lib.mkOption {
      type = lib.types.enum [ "systemd-boot" "grub" "none" ];
      default = "systemd-boot";
      description = "Bootloader type";
    };
    efi = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "EFI boot support";
    };
    kernelPackages = lib.mkOption {
      type = lib.types.enum [ "default" "latest" "lts" ];
      default = "default";
      description = "Kernel package set";
    };
    initrd.availableModules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "ahci" "xhci_pci" "virtio_pci" "virtio_blk" "sr_mod" ];
      description = "Kernel modules for initrd";
    };
  };
}
