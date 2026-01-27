# Core nixvim bindings (non-keymap config)
{ lib, ... }:
{
  config.nixvim.enable = lib.mkDefault true;
}
