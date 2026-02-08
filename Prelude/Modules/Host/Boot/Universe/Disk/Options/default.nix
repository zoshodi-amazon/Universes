# Disk Options - vendor-agnostic declarative disk partitioning
{ lib, ... }:
let
  partitionSubmodule = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Partition name/label";
      };
      size = lib.mkOption {
        type = lib.types.str;
        default = "100%";
        description = "Partition size (e.g., 512M, 100%, remainder)";
      };
      type = lib.mkOption {
        type = lib.types.enum [ "efi" "swap" "root" "persist" "home" ];
        description = "Partition role";
      };
      filesystem = lib.mkOption {
        type = lib.types.enum [ "vfat" "ext4" "btrfs" "xfs" "swap" ];
        default = "ext4";
        description = "Filesystem type";
      };
      mountpoint = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Mount point (null for swap)";
      };
    };
  };

  deviceSubmodule = lib.types.submodule {
    options = {
      device = lib.mkOption {
        type = lib.types.str;
        description = "Block device path (e.g., /dev/sda)";
      };
      tableType = lib.mkOption {
        type = lib.types.enum [ "gpt" "mbr" ];
        default = "gpt";
        description = "Partition table type";
      };
      partitions = lib.mkOption {
        type = lib.types.listOf partitionSubmodule;
        default = [];
        description = "Partition definitions";
      };
    };
  };
in
{
  options.boot-config.disk = {
    enable = lib.mkEnableOption "Declarative disk partitioning";

    devices = lib.mkOption {
      type = lib.types.attrsOf deviceSubmodule;
      default = {};
      description = "Disk device definitions";
    };
  };
}
