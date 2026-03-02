# NixZsh Artifact
{ lib, ... }:
{
  options.shell.zsh = {
    enable = lib.mkEnableOption "Zsh shell";
    aliases = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; description = "Aliases"; };
    paths = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Paths"; };
    initExtra = lib.mkOption { type = lib.types.lines; default = ""; description = "Init extra"; };
  };
}
