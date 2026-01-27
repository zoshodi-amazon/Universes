# Instances: exports to flake.modules.homeManager
{ config, lib, ... }:
let cfg = config.git; in
{
  config.flake.modules.homeManager.git = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = lib.mkIf (cfg.userName != "") cfg.userName;
      userEmail = lib.mkIf (cfg.userEmail != "") cfg.userEmail;
      signing = lib.mkIf (cfg.signing.key != "") {
        key = cfg.signing.key;
        signByDefault = cfg.signing.signByDefault;
      };
      extraConfig = {
        init.defaultBranch = cfg.defaultBranch;
      } // cfg.extraConfig;
      aliases = cfg.aliases;
      delta.enable = cfg.delta.enable;
      lfs.enable = cfg.lfs.enable;
    };
  };
}
