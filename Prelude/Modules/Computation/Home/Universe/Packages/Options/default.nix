# Core packages options
{ lib, ... }:
{
  options.home.corePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [];
    description = "Core package names for all home configurations";
  };
}
