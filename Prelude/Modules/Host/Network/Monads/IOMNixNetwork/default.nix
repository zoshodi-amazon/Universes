# IOMNixNetwork Monad — enables itself
{ lib, ... }:
{
  config.network-config.enable = lib.mkDefault true;
}