# Kitty Instances
{ config, lib, ... }:
let cfg = config.kitty; in
{
  config.flake.modules.homeManager.kitty = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font.name = cfg.font.name;
      font.size = cfg.font.size;
      themeFile = cfg.theme;
      settings = {
        scrollback_lines = 10000;
        enable_audio_bell = false;
        update_check_interval = 0;
      } // cfg.settings;
    };
  };
}
