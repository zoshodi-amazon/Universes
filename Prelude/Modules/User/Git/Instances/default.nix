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
      settings = {
        init.defaultBranch = cfg.defaultBranch;
        alias = cfg.aliases;
      } // cfg.extraConfig;
      lfs.enable = cfg.lfs.enable;
      ignores = cfg.ignores;
    };
    programs.delta = {
      enable = cfg.delta.enable;
      enableGitIntegration = true;
    };
  };
}
