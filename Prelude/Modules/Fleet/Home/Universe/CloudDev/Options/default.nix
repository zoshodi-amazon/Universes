# CloudDev home options
{ lib, ... }:
{
  options.home.cloudDev = {
    enable = lib.mkEnableOption "Cloud-dev home configuration";
    username = lib.mkOption { type = lib.types.str; default = "zoshodi"; };
    homeDirectory = lib.mkOption { type = lib.types.str; default = "/home/zoshodi"; };
    stateVersion = lib.mkOption { type = lib.types.str; default = "24.05"; };
  };
}
