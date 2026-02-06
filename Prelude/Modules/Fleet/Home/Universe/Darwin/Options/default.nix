# Darwin home options
{ lib, ... }:
{
  options.home.darwin = {
    enable = lib.mkEnableOption "Darwin home configuration";
    username = lib.mkOption { type = lib.types.str; default = "zoshodi"; };
    homeDirectory = lib.mkOption { type = lib.types.str; default = "/Users/zoshodi"; };
    stateVersion = lib.mkOption { type = lib.types.str; default = "24.05"; };
  };
}
