# Secrets Env
{ config, lib, ... }:
let
  sops = config.secrets.sops;
in
{
  options.secrets.env = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
  };
  config.secrets.env = lib.mkIf sops.enable {
    SOPS_AGE_KEY_FILE = sops.ageKeyFile;
  };
}
