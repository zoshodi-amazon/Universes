# Deploy Env
{ config, lib, ... }:
let
  cfg = config.deploy;
in
{
  options.deploy.env = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
  };
  config.deploy.env = lib.mkIf cfg.enable {
    DEPLOY_SSH_USER = cfg.sshUser;
  };
}
