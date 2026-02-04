{ lib, ... }:
{
  options.audio.export = {
    input = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Input audio file";
    };
    output = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Output file";
    };
    format = lib.mkOption {
      type = lib.types.enum [ "wav" "mp3" "flac" "ogg" "opus" ];
      default = "mp3";
      description = "Output format";
    };
    bitrate = lib.mkOption {
      type = lib.types.str;
      default = "320k";
      description = "Audio bitrate";
    };
    sampleRate = lib.mkOption {
      type = lib.types.int;
      default = 44100;
      description = "Sample rate in Hz";
    };
  };
}
