{ config, lib, inputs, ... }:
let
  cfg = config.boot-config;

  # Convert our device schema to disko format
  mkPartContent = part:
    if part.type == "efi" then {
      type = "filesystem";
      format = "vfat";
      mountpoint = if part.mountpoint != null then part.mountpoint else "/boot";
    }
    else if part.type == "swap" then {
      type = "swap";
      randomEncryption = true;
    }
    else {
      type = "filesystem";
      format = part.filesystem;
      mountpoint = part.mountpoint;
    };

  mkDiskoDevice = _: dev: {
    type = "disk";
    device = dev.device;
    content = {
      type = dev.tableType;
      partitions = lib.listToAttrs (map (part: {
        name = part.name;
        value = {
          size = part.size;
          content = mkPartContent part;
        };
      }) dev.partitions);
    };
  };
in
{
  config.flake.modules.nixos.boot-config = { pkgs, lib, config, ... }: {
    options.boot-config.enable = lib.mkEnableOption "boot configuration";
    config = lib.mkIf config.boot-config.enable {
      boot.loader.systemd-boot.enable = cfg.loader == "systemd-boot";
      boot.loader.grub.enable = cfg.loader == "grub";
      boot.loader.efi.canTouchEfiVariables = cfg.efi;
      boot.initrd.availableKernelModules = cfg.initrd.availableModules;
      boot.kernelPackages = {
        default = pkgs.linuxPackages;
        latest = pkgs.linuxPackages_latest;
        lts = pkgs.linuxPackages_6_6;
      }.${cfg.kernelPackages};
    };
  };

  config.flake.modules.nixos.disk-config = lib.mkIf cfg.disk.enable {
    imports = [ inputs.disko.nixosModules.disko ];
    disko.devices.disk = lib.mapAttrs mkDiskoDevice cfg.disk.devices;
  };
}
