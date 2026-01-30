# Nix language support plugins
{ config, lib, ... }:
{
  config.nixvim.plugins.nix = lib.mkIf config.nixvim.enable {
    lsp.servers.nil_ls.enable = true;
    none-ls = {
      enable = true;
      sources.formatting.alejandra.enable = true;
    };
  };
}
