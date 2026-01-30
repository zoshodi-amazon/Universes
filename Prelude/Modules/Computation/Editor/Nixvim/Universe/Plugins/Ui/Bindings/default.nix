# UI plugins
{ config, lib, ... }:
{
  config.nixvim.plugins.ui = lib.mkIf config.nixvim.enable {
    web-devicons.enable = true;
    lualine.enable = true;
    bufferline.enable = true;
    indent-blankline.enable = true;
    zen-mode.enable = true;
    which-key = {
      enable = true;
      settings.delay = 200;
    };
  };
}
