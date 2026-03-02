# IOMNixDisplay Monad — enables itself
{ lib, ... }:
{
  config.display.enable = lib.mkDefault false;
}