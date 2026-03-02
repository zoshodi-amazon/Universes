# IOMNixBoot Monad — enables itself
{ lib, ... }:
{
  config.boot-config.enable = lib.mkDefault true;
}
