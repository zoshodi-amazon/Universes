# Navigation plugins
{ config, lib, ... }:
{
  config.nixvim.plugins.navigation = lib.mkIf config.nixvim.enable {
    telescope.enable = true;
    oil.enable = true;
    nvim-tree.enable = true;
    yazi.enable = true;
    treesitter = {
      enable = true;
      folding.enable = true;
    };
  };
}
