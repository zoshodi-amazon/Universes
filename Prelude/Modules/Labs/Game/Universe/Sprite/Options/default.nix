{ lib, ... }:
{
  options.game.sprite = {
    width = lib.mkOption {
      type = lib.types.int;
      default = 16;
    };
    height = lib.mkOption {
      type = lib.types.int;
      default = 16;
    };
    palette = lib.mkOption {
      type = lib.types.enum [ "gameboy" "nes" "pico8" "custom" ];
      default = "pico8";
    };
    frames = lib.mkOption {
      type = lib.types.int;
      default = 1;
    };
  };
}
