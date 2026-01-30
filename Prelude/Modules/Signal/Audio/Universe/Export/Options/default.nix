# Export Options - output format
{ lib, ... }:
{
  options.audio.export = {
    format = lib.mkOption { type = lib.types.enum [ "mp3" "wav" "flac" "opus" "aac" "ogg" ]; default = "mp3"; };
    bitrate = lib.mkOption { type = lib.types.str; default = "320k"; };
    sampleRate = lib.mkOption { type = lib.types.int; default = 44100; };
    channels = lib.mkOption { type = lib.types.enum [ 1 2 ]; default = 2; };
  };
}
