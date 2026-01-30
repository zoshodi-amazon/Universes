# Transform Options - DSP filters
{ lib, ... }:
{
  options.audio.transform = {
    highpass = lib.mkOption { type = lib.types.nullOr lib.types.int; default = null; };
    lowpass = lib.mkOption { type = lib.types.nullOr lib.types.int; default = null; };
    volume = lib.mkOption { type = lib.types.str; default = "1.0"; };
    tempo = lib.mkOption { type = lib.types.str; default = "1.0"; };
    pitch = lib.mkOption { type = lib.types.nullOr lib.types.int; default = null; };
    normalize = lib.mkOption { type = lib.types.bool; default = false; };
  };
}
