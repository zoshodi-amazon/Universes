# IOMNixKitty Monad — enables itself
{ lib, ... }:
{
  config.kitty.enable = lib.mkDefault true;
}
