# Sops Options
{ lib, ... }:
{
  options.secrets.sops = {
    enable = lib.mkEnableOption "sops-nix secrets management";
    defaultSopsFile = lib.mkOption {
      type = lib.types.path;
      default = ../../../secrets.yaml;
      description = "Default sops file for secrets";
    };
    ageKeyFile = lib.mkOption {
      type = lib.types.str;
      default = "~/.config/sops/age/keys.txt";
      description = "Path to age key file";
    };
  };
  config.secrets.sops.enable = lib.mkDefault true;
}
