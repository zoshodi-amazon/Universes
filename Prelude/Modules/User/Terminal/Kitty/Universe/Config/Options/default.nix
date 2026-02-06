# Kitty Options
{ lib, ... }:
{
  options.kitty = {
    enable = lib.mkEnableOption "Kitty terminal";
    font.name = lib.mkOption { type = lib.types.str; default = "JetBrainsMono Nerd Font"; };
    font.size = lib.mkOption { type = lib.types.int; default = 12; };
    theme = lib.mkOption { type = lib.types.str; default = "Tokyo Night"; };
    settings = lib.mkOption { type = lib.types.attrsOf lib.types.anything; default = {}; };
  };
}
