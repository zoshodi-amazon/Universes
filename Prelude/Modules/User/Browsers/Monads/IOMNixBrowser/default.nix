# IOMNixBrowser Monad — enables itself
{ lib, ... }:
{
  config.browser.enable = lib.mkDefault true;
}
