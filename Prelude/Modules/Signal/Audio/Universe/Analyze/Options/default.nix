# Analyze Options - spectral & music-theoretic analysis
{ lib, ... }:
{
  options.audio.analyze = {
    # Spectral
    chromagram = lib.mkOption { type = lib.types.bool; default = false; description = "Pitch class distribution over time"; };
    spectrogram = lib.mkOption { type = lib.types.bool; default = false; description = "Time-frequency representation"; };
    mfcc = lib.mkOption { type = lib.types.bool; default = false; description = "Timbre/texture features"; };
    # Harmonic
    chords = lib.mkOption { type = lib.types.bool; default = false; description = "Chord detection with Roman numerals"; };
    key = lib.mkOption { type = lib.types.bool; default = false; description = "Key estimation"; };
    tonnetz = lib.mkOption { type = lib.types.bool; default = false; description = "Harmonic motion on Tonnetz lattice"; };
    # Rhythmic
    bpm = lib.mkOption { type = lib.types.bool; default = false; description = "Tempo detection"; };
    beats = lib.mkOption { type = lib.types.bool; default = false; description = "Beat grid positions"; };
    downbeats = lib.mkOption { type = lib.types.bool; default = false; description = "Measure boundaries"; };
    # Structural
    segments = lib.mkOption { type = lib.types.bool; default = false; description = "Section boundaries (verse, chorus)"; };
    # Output
    outputDir = lib.mkOption { type = lib.types.str; default = "./analysis"; };
    visualize = lib.mkOption { type = lib.types.bool; default = true; description = "Generate visualizations"; };
  };
}
