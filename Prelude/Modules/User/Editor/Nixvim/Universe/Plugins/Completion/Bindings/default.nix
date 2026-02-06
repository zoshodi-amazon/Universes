# Completion plugins
{ config, lib, ... }:
{
  config.nixvim.plugins.completion = lib.mkIf config.nixvim.enable {
    cmp.enable = true;
    cmp-nvim-lsp.enable = true;
    cmp-buffer.enable = true;
    cmp-path.enable = true;
    luasnip.enable = true;
  };
}
