{ config, lib, pkgs, ... }:
{
  perSystem = { pkgs, ... }: {
    devShells.audio = pkgs.mkShell {
      packages = with pkgs; [ ffmpeg yt-dlp ];
      shellHook = ''
        echo "Audio Lab - ffmpeg-based signal processing"
      '';
    };
  };
}
