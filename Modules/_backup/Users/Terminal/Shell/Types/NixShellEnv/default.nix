# NixShellEnv Artifact — shared env vars and aliases
{ lib, ... }:
{
  options.shell.env = {
    TOOLBOX_BIN = lib.mkOption { type = lib.types.str; default = "$HOME/.toolbox/bin"; description = "Toolbox bin"; };
    LOCAL_BIN = lib.mkOption { type = lib.types.str; default = "$HOME/.local/bin"; description = "Local bin"; };
    NIX_PROFILE = lib.mkOption { type = lib.types.str; default = "$HOME/.nix-profile/bin"; description = "Nix profile"; };
    EDITOR = lib.mkOption { type = lib.types.str; default = "nvim"; description = "Editor"; };
    VISUAL = lib.mkOption { type = lib.types.str; default = "nvim"; description = "Visual"; };
    KEYTIMEOUT = lib.mkOption { type = lib.types.int; default = 1; description = "Keytimeout"; };
    HISTSIZE = lib.mkOption { type = lib.types.int; default = 10000; description = "Histsize"; };
  };
  options.shell.aliases = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; description = "Aliases"; };
}
