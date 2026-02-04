{ lib, ... }:
{
  options.sovereignty.transport = {
    modes = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [ "foot" "bicycle" "motorcycle" "vehicle" "boat" "aircraft" ]);
      default = [ "foot" "bicycle" ];
    };
    navigation = {
      gps = lib.mkEnableOption "GPS navigation";
      gpsDenied = lib.mkEnableOption "GPS-denied navigation (celestial, terrain, inertial)";
      maps.offline = lib.mkEnableOption "offline maps";
    };
    fuel = lib.mkOption {
      type = lib.types.enum [ "human" "electric" "gasoline" "diesel" "multi" ];
      default = "human";
    };
    signature = {
      visual = lib.mkOption { type = lib.types.enum [ "distinctive" "common" "camouflaged" ]; default = "common"; };
      electronic = lib.mkOption { type = lib.types.enum [ "tracked" "minimal" "dark" ]; default = "minimal"; };
    };
  };
}
