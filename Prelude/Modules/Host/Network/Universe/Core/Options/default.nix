{ lib, ... }:
{
  options.network-config = {
    enable = lib.mkEnableOption "system networking";
    dhcp = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable DHCP";
    };
    firewall = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable firewall";
      };
      allowedTCPPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ 22 ];
        description = "Allowed TCP ports";
      };
    };
    ssh.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable SSH daemon";
    };
    wireless.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable wireless networking";
    };
  };
}
