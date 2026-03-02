# NixCloudDev Artifact
{ lib, ... }:
{
  options.home.cloudDev = {
    enable = lib.mkEnableOption "Cloud-dev home configuration";
    username = lib.mkOption { type = lib.types.str; default = "zoshodi"; description = "Username"; };
    homeDirectory = lib.mkOption { type = lib.types.str; default = "/home/zoshodi"; description = "Home directory"; };
    stateVersion = lib.mkOption { type = lib.types.str; default = "24.05"; description = "State version"; };
  };
}