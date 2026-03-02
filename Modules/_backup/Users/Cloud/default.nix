# Cloud — global instantiation
# AWS CLI profiles via programs.awscli home-manager module
{ config, lib, ... }:
let
  cfg = config.cloud;
in
{
  config.flake.modules.homeManager.cloud = lib.mkIf cfg.enable {
    programs.awscli = {
      enable = true;
      settings = { default = { region = cfg.defaultRegion; output = cfg.defaultOutput; }; } // cfg.profiles;
    };
  };
}
