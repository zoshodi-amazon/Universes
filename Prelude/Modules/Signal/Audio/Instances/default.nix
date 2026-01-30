# Audio Instances - wire options to devShell
{ config, lib, ... }:
let
  cfg = config.audio;
  envVars = {
    AUDIO_ACQUIRE_FORMAT = cfg.acquire.format;
    AUDIO_ACQUIRE_OUTPUT_DIR = cfg.acquire.outputDir;
    AUDIO_ANALYZE_OUTPUT_DIR = cfg.analyze.outputDir;
    AUDIO_ANALYZE_VISUALIZE = lib.boolToString cfg.analyze.visualize;
    AUDIO_TRANSFORM_VOLUME = cfg.transform.volume;
    AUDIO_TRANSFORM_TEMPO = cfg.transform.tempo;
    AUDIO_TRANSFORM_NORMALIZE = lib.boolToString cfg.transform.normalize;
    AUDIO_EXPORT_FORMAT = cfg.export.format;
    AUDIO_EXPORT_BITRATE = cfg.export.bitrate;
    AUDIO_EXPORT_SAMPLE_RATE = toString cfg.export.sampleRate;
    AUDIO_EXPORT_CHANNELS = toString cfg.export.channels;
  };
in
{
  config.audio.enable = lib.mkDefault true;

  config.perSystem = { pkgs, ... }: lib.mkIf cfg.enable {
    devShells.audio = pkgs.mkShell {
      name = "audio-dev";
      packages = with pkgs; [
        ffmpeg
        yt-dlp
        sox
        (python311.withPackages (ps: with ps; [
          librosa        # chromagram, spectrogram, mfcc
          matplotlib     # visualization
          numpy
          scipy
          soundfile
        ]))
      ];
      shellHook = ''
        echo "Audio Engineering Shell"
        echo "  DSP: ffmpeg, sox"
        echo "  Acquire: yt-dlp"
        echo "  Analysis: librosa, matplotlib"
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "export ${k}=\"${v}\"") envVars)}
      '';
    };
  };
}
