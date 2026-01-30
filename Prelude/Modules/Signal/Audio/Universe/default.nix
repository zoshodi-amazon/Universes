# Audio Universe - root options
{ lib, ... }:
{
  options.audio.enable = lib.mkEnableOption "Audio engineering pipeline";
}
