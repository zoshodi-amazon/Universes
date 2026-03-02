# IOMNixDisk — wires disk types into disko NixOS module
{ config, lib, inputs, ... }:
let
  cfg = config.disk;

  mkEfiPartition = {
    size = "512M";
    content = { type = "filesystem"; format = "vfat"; mountpoint = "/boot"; };
  };

  mkSwapPartition = size: {
    inherit size;
    content = { type = "swap"; randomEncryption = true; };
  };

  mkRootPartition = filesystem: encryption: {
    size = "100%";
    content =
      if encryption == "luks" then {
        type = "luks"; name = "cryptroot";
        content = { type = "filesystem"; format = filesystem; mountpoint = "/"; };
      }
      else { type = "filesystem"; format = filesystem; mountpoint = "/"; };
  };

  mkSingleDisk = dev: {
    type = "disk";
    device = dev.device;
    content = {
      type = dev.tableType;
      partitions = {
        ESP = mkEfiPartition;
      }
      // lib.optionalAttrs (cfg.swapSize != "none") {
        swap = mkSwapPartition cfg.swapSize;
      }
      // {
        root = mkRootPartition cfg.filesystem cfg.encryption;
      };
    };
  };

  mkCustomDisk = _: dev: {
    type = "disk";
    device = dev.device;
    content = {
      type = dev.tableType;
      partitions = lib.listToAttrs (map (part: {
        name = part.name;
        value = {
          size = part.size;
          content =
            if part.role == "efi" then { type = "filesystem"; format = "vfat"; mountpoint = "/boot"; }
            else if part.role == "swap" then { type = "swap"; randomEncryption = true; }
            else { type = "filesystem"; format = cfg.filesystem; mountpoint = "/${part.role}"; };
        };
      }) dev.partitions);
    };
  };
in
{
  config.flake.modules.nixos.disk-config = lib.mkIf cfg.enable ({ pkgs, ... }: {
    imports = [ inputs.disko.nixosModules.disko ];

    disko.devices.disk =
      if cfg.layout == "single-disk" then
        lib.mapAttrs (_: mkSingleDisk) cfg.devices
      else
        lib.mapAttrs mkCustomDisk cfg.devices;

    # Remote unlock via SSH in initrd
    boot.initrd.network = lib.mkIf cfg.remoteUnlock {
      enable = true;
      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
      };
    };
  });
}
