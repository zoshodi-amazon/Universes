{ lib, ... }:
{
  options.nixosSystems.core = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
    };
    locale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
    };
    timezone = lib.mkOption {
      type = lib.types.str;
      default = "UTC";
    };
    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "24.11";
    };
    networking = {
      firewall = lib.mkEnableOption "firewall" // { default = true; };
      ssh = lib.mkEnableOption "SSH server" // { default = true; };
      networkManager = lib.mkEnableOption "NetworkManager" // { default = true; };
    };
  };
}
