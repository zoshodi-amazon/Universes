# Home Env
{ config, lib, ... }:
let
  darwin = config.home.darwin;
  cloudDev = config.home.cloudDev;
  cloudNix = config.home.cloudNix;
in
{
  options.home.env = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
  config.home.env = {
    HOME_DARWIN_ENABLED = lib.boolToString darwin.enable;
    HOME_CLOUD_DEV_ENABLED = lib.boolToString cloudDev.enable;
    HOME_CLOUD_NIX_ENABLED = lib.boolToString cloudNix.enable;
  };
}
