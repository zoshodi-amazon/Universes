{ lib, ... }:
{
  options.game.render = {
    dimension = lib.mkOption {
      type = lib.types.enum [ "2d" "3d" ];
      default = "2d";
    };
    resolution = lib.mkOption {
      type = lib.types.str;
      default = "320x240";
    };
    backend = lib.mkOption {
      type = lib.types.enum [ "aseprite" "blender" "imagemagick" ];
      default = "aseprite";
    };
    palette = lib.mkOption {
      type = lib.types.enum [ "gameboy" "nes" "pico8" "custom" ];
      default = "pico8";
    };
  };
}
