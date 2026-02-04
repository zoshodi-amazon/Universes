{ lib, ... }:
{
  options.sovereignty.medical = {
    level = lib.mkOption {
      type = lib.types.enum [ "firstaid" "emt" "paramedic" "field-surgery" ];
      default = "firstaid";
    };
    pharmacy = {
      enable = lib.mkEnableOption "pharmaceutical capability";
      synthesis = lib.mkEnableOption "compound synthesis";
      botanical = lib.mkEnableOption "botanical medicine";
    };
    diagnostics = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [ "vitals" "blood" "imaging" "lab" ]);
      default = [ "vitals" ];
    };
    telemedicine.enable = lib.mkEnableOption "remote medical consultation";
  };
}
