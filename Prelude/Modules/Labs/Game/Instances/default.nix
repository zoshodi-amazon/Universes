# Game Instances - export devShell + packages
{ config, lib, ... }:
let
  cfg = config.game;
  scripts = ../Universe;
in
{
  config.perSystem = { pkgs, ... }: lib.mkIf cfg.enable {
    devShells.game = pkgs.mkShell {
      name = "game";
      packages = with pkgs; [
        # 2D (imagemagick covers create/composite/montage/animate)
        imagemagick
        # 3D (blender currently broken in nixpkgs -- add via Drv/ when needed)
        # blender
        # Preview
        chafa
        watchexec
        # Audio
        ffmpeg
        # Util
        gum
        nushell
        curl
        sqlite
      ];
      shellHook = ''
        mkdir -p .lab/sprites .lab/renders .lab/audio .lab/assets .lab/models .lab/exports
        echo "Game Design Lab"
        echo "  just --list"
      '';
    };
  };
}
