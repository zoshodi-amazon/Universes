# RenderersIO: audio-specific renderers
{ config, lib, pkgs, ... }:
{
  config.renderers = lib.mkForce (with pkgs; [
    ffmpeg
    sox
    lame
    flac
  ]);
}
