{ lib, ... }:
{
  options.audio.synthesize = {
    waveform = lib.mkOption {
      type = lib.types.enum [ "sine" "square" "triangle" "sawtooth" "noise" ];
      default = "sine";
      description = "Oscillator waveform";
    };
    frequency = lib.mkOption {
      type = lib.types.int;
      default = 440;
      description = "Frequency in Hz";
    };
    duration = lib.mkOption {
      type = lib.types.str;
      default = "1";
      description = "Duration in seconds";
    };
    envelope = lib.mkOption {
      type = lib.types.submodule {
        options = {
          attack = lib.mkOption { type = lib.types.str; default = "0.01"; };
          decay = lib.mkOption { type = lib.types.str; default = "0.1"; };
          sustain = lib.mkOption { type = lib.types.str; default = "0.7"; };
          release = lib.mkOption { type = lib.types.str; default = "0.2"; };
        };
      };
      default = {};
      description = "ADSR envelope";
    };
    output = lib.mkOption {
      type = lib.types.str;
      default = "./synth.wav";
      description = "Output file";
    };
  };
}
