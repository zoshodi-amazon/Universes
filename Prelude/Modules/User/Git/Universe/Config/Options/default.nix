# Git Config Options
{ lib, ... }:
{
  options.git = {
    enable = lib.mkEnableOption "Git configuration";
    userName = lib.mkOption { type = lib.types.str; default = ""; };
    userEmail = lib.mkOption { type = lib.types.str; default = ""; };
    signing = {
      key = lib.mkOption { type = lib.types.str; default = ""; };
      signByDefault = lib.mkOption { type = lib.types.bool; default = false; };
    };
    defaultBranch = lib.mkOption { type = lib.types.str; default = "main"; };
    aliases = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
    extraConfig = lib.mkOption { type = lib.types.attrsOf lib.types.anything; default = {}; };
    delta.enable = lib.mkOption { type = lib.types.bool; default = true; };
    lfs.enable = lib.mkOption { type = lib.types.bool; default = false; };
  };
}
