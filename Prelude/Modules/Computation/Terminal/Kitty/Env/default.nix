# Kitty Env
{ config, lib, ... }:
let cfg = config.kitty; in
{
  options.kitty.env = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
  config.kitty.env = lib.mkIf cfg.enable {
    KITTY_FONT = cfg.font.name;
    KITTY_FONT_SIZE = toString cfg.font.size;
    KITTY_THEME = cfg.theme;
  };
}
