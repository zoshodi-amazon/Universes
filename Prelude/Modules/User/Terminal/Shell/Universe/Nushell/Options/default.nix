{ lib, ... }:
{
  options.shell.nushell = {
    enable = lib.mkEnableOption "Nushell";
    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
    };
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    configExtra = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
    envExtra = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
  };
}
