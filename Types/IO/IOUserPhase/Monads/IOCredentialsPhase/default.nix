# IOCredentialsPhase (Crystalline) — git author, signing, ignores
{ config, lib, ... }:
let
  cfg = builtins.fromJSON (builtins.readFile ../../default.json);
  git = cfg.git;
in
{
  config.flake.modules.homeManager.git = lib.mkIf git.enable {
    programs.git = {
      enable = true;
      userName = lib.mkIf (git.userName != "") git.userName;
      userEmail = lib.mkIf (git.userEmail != "") git.userEmail;
      signing = lib.mkIf (git.signing.key != "") { key = git.signing.key; signByDefault = git.signing.signByDefault; };
      settings = { init.defaultBranch = git.defaultBranch; alias = git.aliases; } // git.extraConfig;
      lfs.enable = git.lfs; ignores = git.ignores;
    };
    programs.delta = { enable = git.delta; enableGitIntegration = true; };
  };
}
