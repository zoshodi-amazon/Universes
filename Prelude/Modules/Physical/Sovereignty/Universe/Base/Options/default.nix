{ lib, ... }:
{
  options.sovereignty.modes.base = {
    permanence = lib.mkOption {
      type = lib.types.enum [ "temporary" "seasonal" "semi-permanent" "permanent" ];
      default = "semi-permanent";
    };
    expansionCapacity = lib.mkOption { type = lib.types.int; default = 4; description = "Max people supported"; };
    redundancy = lib.mkOption {
      type = lib.types.enum [ "none" "n+1" "2n" ];
      default = "n+1";
      description = "System redundancy level";
    };
    cacheLocations = lib.mkOption { type = lib.types.int; default = 0; description = "Number of supply caches"; };
  };
}
