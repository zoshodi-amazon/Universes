# CloudNix home options
{ lib, ... }:
{
  options.home.cloudNix = {
    enable = lib.mkEnableOption "Cloud-nix home configuration";
    username = lib.mkOption { type = lib.types.str; default = "zoshodi"; };
    homeDirectory = lib.mkOption { type = lib.types.str; default = "/home/zoshodi"; };
    stateVersion = lib.mkOption { type = lib.types.str; default = "24.05"; };
  };
}
