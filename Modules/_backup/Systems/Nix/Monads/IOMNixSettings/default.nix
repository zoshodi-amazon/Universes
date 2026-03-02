# IOMNixSettings Monad — enables itself
{ lib, ... }:
{
  config.nix-settings.enable = lib.mkDefault true;
}