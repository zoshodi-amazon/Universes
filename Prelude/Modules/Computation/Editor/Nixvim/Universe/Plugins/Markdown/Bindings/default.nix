# Markdown plugins
{ config, lib, ... }:
{
  config.nixvim.plugins.markdown = lib.mkIf config.nixvim.enable {
    glow.enable = true;
    markdown-preview = {
      enable = true;
      autoLoad = true;
    };
  };
}
