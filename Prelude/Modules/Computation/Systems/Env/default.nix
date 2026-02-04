# Systems Env - aggregates Universe options to ENV vars
{ lib, config, ... }:
let
  cfg = config.nixosSystems;
in
{
  options.nixosSystems.env = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    description = "Environment variables for nixosSystems";
  };
  
  config.nixosSystems.env = {
    NIXOS_PROFILE = cfg.profile;
    NIXOS_TARGET = cfg.hardware.target;
    NIXOS_FORMAT = cfg.hardware.format;
    NIXOS_HOSTNAME = cfg.core.hostname;
    NIXOS_USERNAME = cfg.core.username;
  };
}
