# EnvIO: Audio workbench shell customization
{ config, lib, pkgs, ... }:
{
  config.devShells.default = lib.mkForce (pkgs.mkShell {
    packages = config.renderers ++ config.interpreters ++ [ config.formatter ] ++ (with pkgs; [
      mediainfo
      watchexec
    ]);
    
    env = {
      AUDIO_INPUT_DIR = "$HOME/Media/Audio/Inputs";
      AUDIO_OUTPUT_DIR = "$HOME/Media/Audio/Outputs";
      AUDIO_SAMPLE_RATE = "48000";
      AUDIO_BIT_DEPTH = "24";
    };
    
    shellHook = ''
      mkdir -p "$AUDIO_INPUT_DIR" "$AUDIO_OUTPUT_DIR"
      echo "🎵 Audio Workbench Ready"
    '';
  });
}
