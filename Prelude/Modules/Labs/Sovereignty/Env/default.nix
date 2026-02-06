{ lib, ... }:
{
  options.sovereignty = {
    mode = lib.mkOption {
      type = lib.types.enum [ "nomadic" "urban" "base" ];
      default = "base";
      description = "Operational mode";
    };
    bootstrap.seed = lib.mkOption {
      type = lib.types.enum [ "knowledge" "energy" "compute" ];
      default = "knowledge";
      description = "Bootstrap priority - what capability bootstraps others";
    };
    fabrication.tier = lib.mkOption {
      type = lib.types.enum [ "assembly" "component" "material" ];
      default = "assembly";
      description = "Fabrication depth capability";
    };
    opsec = {
      physical.enable = lib.mkEnableOption "physical signature management";
      signal.enable = lib.mkEnableOption "RF/EM signature management";
      digital.enable = lib.mkEnableOption "digital trail management";
      social.enable = lib.mkEnableOption "behavioral pattern management";
      financial.enable = lib.mkEnableOption "economic trail management";
      temporal.enable = lib.mkEnableOption "timing pattern management";
      legal.enable = lib.mkEnableOption "jurisdiction/documentation management";
    };
  };
}
