{ lib, ... }:
let
  transformType = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = lib.types.enum [ "pitch" "stretch" "filter" "volume" "reverb" "normalize" ];
        description = "Transform type";
      };
      params = lib.mkOption {
        type = lib.types.attrs;
        default = {};
        description = "Transform parameters";
      };
    };
  };
in
{
  options.audio.transform = {
    input = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Input audio file";
    };
    output = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Output audio file";
    };
    transforms = lib.mkOption {
      type = lib.types.listOf transformType;
      default = [];
      description = "List of transforms to apply (in order)";
      example = [
        { type = "filter"; params = { kind = "highpass"; freq = 200; }; }
        { type = "pitch"; params = { semitones = 3; }; }
        { type = "normalize"; params = {}; }
      ];
    };
  };
}
