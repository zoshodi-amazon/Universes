# Disk Bindings - maps Options -> disko format
{ config, lib, ... }:
let
  cfg = config.boot-config.disk;

  # Map partition type to disko content
  mkPartContent = part:
    if part.type == "efi" then {
      type = "filesystem";
      format = "vfat";
      mountpoint = part.mountpoint or "/boot";
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

  # Convert our device schema to disko format
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
  config.boot-config.disk.enable = lib.mkDefault (cfg.devices != {});
}
