# NixGit Artifact — typed option space for Git configuration
{ lib, ... }:
{
  options.git = {
    enable = lib.mkEnableOption "Git configuration";
    userName = lib.mkOption { type = lib.types.str; default = ""; description = "User name"; };
    userEmail = lib.mkOption { type = lib.types.str; default = ""; description = "User email"; };
    signing = {
      key = lib.mkOption { type = lib.types.str; default = ""; description = "Key"; };
      signByDefault = lib.mkOption { type = lib.types.bool; default = false; description = "Sign by default"; };
    };
    defaultBranch = lib.mkOption { type = lib.types.str; default = "main"; description = "Default branch"; };
    aliases = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; description = "Aliases"; };
    extraConfig = lib.mkOption { type = lib.types.attrsOf lib.types.anything; default = {}; description = "Extra config"; };
    delta.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable"; };
    lfs.enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable"; };
    ignores = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Global gitignore patterns"; };
  };
}
