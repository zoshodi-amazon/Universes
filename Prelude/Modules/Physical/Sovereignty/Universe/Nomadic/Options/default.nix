{ lib, ... }:
{
  options.sovereignty.modes.nomadic = {
    teardownTime = lib.mkOption { type = lib.types.str; default = "15min"; description = "Max time to pack and move"; };
    maxWeight = lib.mkOption { type = lib.types.str; default = "25kg"; description = "Max carry weight"; };
    maxVolume = lib.mkOption { type = lib.types.str; default = "65L"; description = "Max pack volume"; };
    mobility = lib.mkOption {
      type = lib.types.enum [ "foot" "bicycle" "motorcycle" "vehicle" ];
      default = "foot";
    };
  };
}
