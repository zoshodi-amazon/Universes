# NixKitty Artifact
{ lib, ... }:
{
  options.kitty = {
    enable = lib.mkEnableOption "Kitty terminal";
    font.name = lib.mkOption { type = lib.types.str; default = "JetBrainsMono Nerd Font"; description = "Name"; };
    font.size = lib.mkOption { type = lib.types.int; default = 12; description = "Size"; };
    theme = lib.mkOption { type = lib.types.str; default = "tokyo_night_night"; description = "Theme"; };
    settings = lib.mkOption { type = lib.types.attrsOf lib.types.anything; default = {}; description = "Settings"; };
  };
}
