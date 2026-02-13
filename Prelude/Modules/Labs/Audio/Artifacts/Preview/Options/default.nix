{ lib, ... }:
{
  options.audio.preview = {
    input = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Audio file to preview";
    };
    mode = lib.mkOption {
      type = lib.types.enum [ "play" "waveform" "spectrum" ];
      default = "play";
      description = "Preview mode";
    };
  };
}
