{ config, lib, ... }:
let
  cfg = config.network-config;
in
{
  config.flake.modules.nixos.network-config = { lib, config, ... }: {
    options.network-config.enable = lib.mkEnableOption "system networking";
    config = lib.mkIf config.network-config.enable {
      networking.useDHCP = cfg.dhcp;
      networking.firewall.enable = cfg.firewall.enable;
      networking.firewall.allowedTCPPorts = cfg.firewall.allowedTCPPorts;
      networking.wireless.enable = cfg.wireless.enable;
      services.openssh.enable = cfg.ssh.enable;
      services.openssh.settings.PermitRootLogin = "prohibit-password";
    };
  };
}
