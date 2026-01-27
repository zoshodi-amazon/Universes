# Darwin Bindings - enable darwin home configuration
{ lib, ... }:
{
  config.home.darwin.enable = lib.mkDefault true;
}
