# Env: aggregates Universe/*/Options → ENV vars
{ config, lib, ... }:
let cfg = config.git; in
{
  options.git.env = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
  config.git.env = lib.mkIf cfg.enable {
    GIT_USER_NAME = cfg.userName;
    GIT_USER_EMAIL = cfg.userEmail;
    GIT_DEFAULT_BRANCH = cfg.defaultBranch;
    GIT_SIGNING_KEY = cfg.signing.key;
    GIT_SIGN_BY_DEFAULT = lib.boolToString cfg.signing.signByDefault;
    GIT_DELTA_ENABLED = lib.boolToString cfg.delta.enable;
    GIT_LFS_ENABLED = lib.boolToString cfg.lfs.enable;
  };
}
