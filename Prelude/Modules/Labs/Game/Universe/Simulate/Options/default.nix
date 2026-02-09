{ lib, ... }:
{
  options.game.simulate = {
    engine = lib.mkOption {
      type = lib.types.enum [ "blender" "custom" ];
      default = "blender";
    };
    timeStep = lib.mkOption {
      type = lib.types.str;
      default = "0.016";
    };
    gravity = lib.mkOption {
      type = lib.types.str;
      default = "9.81";
    };
  };
}
