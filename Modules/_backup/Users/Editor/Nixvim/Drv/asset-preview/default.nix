# asset-preview: universal browser-based asset preview server
{ config, lib, ... }:
{
  config.perSystem = { pkgs, ... }: lib.mkIf config.nixvim.preview.enable {
    packages.asset-preview = pkgs.buildGoModule {
      pname = "asset-preview";
      version = "0.1.0";
      src = ./src;
      vendorHash = null;
      meta.description = "Universal browser-based asset preview server for Neovim";
    };
  };
}