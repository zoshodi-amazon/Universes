{ lib, ... }:
{
  options.sovereignty.intelligence = {
    osint = {
      enable = lib.mkEnableOption "OSINT capabilities";
      domains = lib.mkOption {
        type = lib.types.listOf (lib.types.enum [ "social" "geospatial" "domain" "image" "video" "document" "darkweb" ]);
        default = [ "social" "geospatial" "image" ];
        description = "OSINT domains to enable";
      };
    };
    sigint = {
      enable = lib.mkEnableOption "SIGINT capabilities";
      sdr = lib.mkEnableOption "software-defined radio";
      spectrum = lib.mkEnableOption "spectrum analysis";
      protocol = lib.mkEnableOption "protocol analysis";
    };
    countersurveillance = {
      enable = lib.mkEnableOption "counter-surveillance";
      rf = lib.mkEnableOption "RF sweep/detection";
      camera = lib.mkEnableOption "camera detection";
      tscm = lib.mkEnableOption "technical surveillance countermeasures";
    };
    re = {
      software = lib.mkEnableOption "software reverse engineering";
      hardware = lib.mkEnableOption "hardware reverse engineering";
      firmware = lib.mkEnableOption "firmware extraction/analysis";
      protocol = lib.mkEnableOption "protocol reverse engineering";
    };
  };
}
