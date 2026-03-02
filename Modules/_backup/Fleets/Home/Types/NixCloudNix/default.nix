# NixCloudNix Artifact
{ lib, ... }:
{
  options.home.cloudNix = {
    enable = lib.mkEnableOption "Cloud-nix home configuration";
    username = lib.mkOption { type = lib.types.str; default = "zoshodi"; description = "Username"; };
    homeDirectory = lib.mkOption { type = lib.types.str; default = "/home/zoshodi"; description = "Home directory"; };
    stateVersion = lib.mkOption { type = lib.types.str; default = "24.05"; description = "State version"; };
  };
}