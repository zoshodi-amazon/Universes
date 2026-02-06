{ lib, ... }:
{
  options.shell.zsh = {
    enable = lib.mkEnableOption "Zsh shell";
    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
    };
    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    initExtra = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
  };
}
