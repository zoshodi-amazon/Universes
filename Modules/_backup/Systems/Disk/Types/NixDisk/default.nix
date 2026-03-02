# NixDisk — typed option space for declarative disk management
# 3 orthogonal concerns: layout, filesystem, encryption
{ lib, ... }:
let
  partitionSubmodule = lib.types.submodule {
    options = {
      name = lib.mkOption { type = lib.types.str; description = "Partition name/label"; };
      size = lib.mkOption { type = lib.types.str; default = "100%"; description = "Partition size"; };
      role = lib.mkOption { type = lib.types.enum [ "efi" "swap" "root" "persist" "home" "nix" ]; description = "Partition role"; };
    };
  };
  deviceSubmodule = lib.types.submodule {
    options = {
      device = lib.mkOption { type = lib.types.str; description = "Block device path (e.g. /dev/sda or /dev/disk/by-id/...)"; };
      tableType = lib.mkOption { type = lib.types.enum [ "gpt" "mbr" ]; default = "gpt"; description = "Partition table type"; };
      partitions = lib.mkOption { type = lib.types.listOf partitionSubmodule; default = []; description = "Partition definitions"; };
    };
  };
in
{
  options.disk = {
    enable = lib.mkEnableOption "Declarative disk management";
    layout = lib.mkOption {
      type = lib.types.enum [ "single-disk" "multi-disk" "custom" ];
      default = "single-disk";
      description = "Disk layout strategy";
    };
    filesystem = lib.mkOption {
      type = lib.types.enum [ "ext4" "btrfs" "zfs" ];
      default = "ext4";
      description = "Root filesystem type";
    };
    encryption = lib.mkOption {
      type = lib.types.enum [ "none" "luks" "zfs-native" ];
      default = "none";
      description = "Disk encryption method";
    };
    remoteUnlock = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable SSH-based remote LUKS/ZFS unlock in initrd";
    };
    devices = lib.mkOption {
      type = lib.types.attrsOf deviceSubmodule;
      default = {};
      description = "Disk device definitions for disko";
    };
    swapSize = lib.mkOption {
      type = lib.types.str;
      default = "none";
      description = "Swap partition size (e.g. 8G) or none";
    };
  };
}
