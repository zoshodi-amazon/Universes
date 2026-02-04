{ lib, ... }:
{
  options.audio.compose = {
    inputs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Input audio files";
    };
    mode = lib.mkOption {
      type = lib.types.enum [ "sequence" "layer" ];
      default = "sequence";
      description = "Composition mode";
    };
    output = lib.mkOption {
      type = lib.types.str;
      default = "./composed.wav";
      description = "Output file";
    };
  };
}
