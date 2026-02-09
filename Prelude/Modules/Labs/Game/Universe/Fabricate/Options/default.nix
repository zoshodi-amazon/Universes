{ lib, ... }:
{
  options.game.fabricate = {
    format = lib.mkOption {
      type = lib.types.enum [ "stl" "3mf" "obj" ];
      default = "stl";
    };
    layerHeight = lib.mkOption {
      type = lib.types.str;
      default = "0.2";
    };
    infill = lib.mkOption {
      type = lib.types.str;
      default = "20";
    };
  };
}
