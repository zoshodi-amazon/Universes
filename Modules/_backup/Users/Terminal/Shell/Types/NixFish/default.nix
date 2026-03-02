# NixFish Artifact
{ lib, ... }:
{
  options.shell.fish = {
    enable = lib.mkEnableOption "Fish shell";
    aliases = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; description = "Aliases"; };
    paths = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Paths"; };
    initExtra = lib.mkOption { type = lib.types.lines; default = ""; description = "Init extra"; };
    interactiveShellInit = lib.mkOption { type = lib.types.lines; default = ""; description = "Interactive shell init"; };
  };
}
