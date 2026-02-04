{ lib, ... }:
{
  options.audio.analyze = {
    input = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Input audio file";
    };
    spectrum = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Generate spectrum image";
    };
    waveform = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Generate waveform image";
    };
    loudness = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Measure loudness (LUFS, RMS, peak)";
    };
    outputDir = lib.mkOption {
      type = lib.types.str;
      default = "./analysis";
      description = "Output directory";
    };
  };
}
