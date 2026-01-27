# Git plugins
{ config, lib, ... }:
{
  config.nixvim.plugins.git = lib.mkIf config.nixvim.enable {
    gitsigns.enable = true;
    fugitive.enable = true;
  };
}
