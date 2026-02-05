{ lib, ... }:
let
  dialType = lib.types.submodule {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Dial identifier";
      };
      label = lib.mkOption {
        type = lib.types.str;
        description = "Display label";
      };
      min = lib.mkOption {
        type = lib.types.float;
        description = "Minimum value (domain-native)";
      };
      max = lib.mkOption {
        type = lib.types.float;
        description = "Maximum value (domain-native)";
      };
      default = lib.mkOption {
        type = lib.types.float;
        description = "Default value (domain-native)";
      };
      unit = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Unit label (Hz, dB, etc.)";
      };
      scale = lib.mkOption {
        type = lib.types.enum [ "linear" "log" "exp" ];
        default = "linear";
        description = "Scale for normalization";
      };
      normalized = lib.mkOption {
        type = lib.types.float;
        default = 0.5;
        description = "Normalized value (0.0-1.0)";
      };
    };
  };
in
{
  options.lab.dials = {
    definitions = lib.mkOption {
      type = lib.types.listOf dialType;
      default = [];
      description = "Dial definitions (orthogonal basis coefficients)";
      example = [
        { name = "freq"; label = "Frequency"; min = 20.0; max = 20000.0; default = 1000.0; unit = "Hz"; scale = "log"; }
        { name = "gain"; label = "Gain"; min = -60.0; max = 0.0; default = -12.0; unit = "dB"; scale = "linear"; }
      ];
    };
    values = lib.mkOption {
      type = lib.types.attrsOf lib.types.float;
      default = {};
      description = "Current dial values (normalized 0.0-1.0)";
    };
  };
}
