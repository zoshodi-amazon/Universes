# NixDarwin Artifact
{ lib, ... }:
{
  options.home.darwin = {
    enable = lib.mkEnableOption "Darwin home configuration";
    username = lib.mkOption { type = lib.types.str; default = "zoshodi"; description = "Username"; };
    homeDirectory = lib.mkOption { type = lib.types.str; default = "/Users/zoshodi"; description = "Home directory"; };
    stateVersion = lib.mkOption { type = lib.types.str; default = "24.05"; description = "State version"; };
  };
}