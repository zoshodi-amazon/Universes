{ lib, ... }:
{
  options.sovereignty.defense = {
    perimeter = {
      enable = lib.mkEnableOption "perimeter security";
      sensors = lib.mkOption {
        type = lib.types.listOf (lib.types.enum [ "motion" "seismic" "acoustic" "thermal" "rf" ]);
        default = [];
      };
    };
    earlyWarning = {
      enable = lib.mkEnableOption "early warning system";
      range = lib.mkOption { type = lib.types.str; default = "100m"; };
    };
    physical = {
      hardening = lib.mkOption { type = lib.types.enum [ "none" "basic" "reinforced" "fortified" ]; default = "none"; };
      concealment = lib.mkOption { type = lib.types.enum [ "none" "camouflage" "decoy" "underground" ]; default = "none"; };
    };
    commsec.enable = lib.mkEnableOption "communications security";
  };
}
