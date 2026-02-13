# NixShellEnv Artifact — shared env vars and aliases
{ lib, ... }:
{
  options.shell.env = {
    TOOLBOX_BIN = lib.mkOption { type = lib.types.str; default = "$HOME/.toolbox/bin"; };
    LOCAL_BIN = lib.mkOption { type = lib.types.str; default = "$HOME/.local/bin"; };
    NIX_PROFILE = lib.mkOption { type = lib.types.str; default = "$HOME/.nix-profile/bin"; };
    EDITOR = lib.mkOption { type = lib.types.str; default = "nvim"; };
    VISUAL = lib.mkOption { type = lib.types.str; default = "nvim"; };
    KEYTIMEOUT = lib.mkOption { type = lib.types.int; default = 1; };
    HISTSIZE = lib.mkOption { type = lib.types.int; default = 10000; };
  };
  options.shell.aliases = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
}
