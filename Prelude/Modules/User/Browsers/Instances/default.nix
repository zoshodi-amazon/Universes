# Instances: exports to flake.modules.homeManager
{ config, lib, ... }:
let cfg = config.browsers.firefox; in
{
  config.flake.modules.homeManager.firefox = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles = lib.mapAttrs (name: profile: {
        inherit (profile) isDefault settings;
      }) cfg.profiles;
    };
  };
}
