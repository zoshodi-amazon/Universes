# NixNushell Artifact
{ lib, ... }:
{
  options.shell.nushell = {
    enable = lib.mkEnableOption "Nushell";
    aliases = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; description = "Aliases"; };
    paths = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Paths"; };
    configExtra = lib.mkOption { type = lib.types.lines; default = ""; description = "Config extra"; };
    envExtra = lib.mkOption { type = lib.types.lines; default = ""; description = "Env extra"; };
  };
}
