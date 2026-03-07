# IONetworkPhase (Liquid Crystal) — system networking + user SSH
{ config, lib, ... }:
let
  base = builtins.fromJSON (builtins.readFile ./default.json);
  local =
    if builtins.pathExists ./local.json then
      builtins.fromJSON (builtins.readFile ./local.json)
    else
      { };
  cfg = lib.recursiveUpdate base local;
  net = cfg.network;
  ssh = cfg.ssh;
  hosts = cfg.hosts or { };
  hostToMatch = name: host: {
    hostname = host.hostname;
    user = lib.mkIf (host.user or "" != "") (host.user or "");
    port = host.port or 22;
    identityFile = lib.mkIf (host.identityFile or "" != "") (host.identityFile or "");
    forwardAgent = host.forwardAgent or false;
    extraOptions = host.extraOptions or { };
  };
in
{
  config.flake.modules.nixos.network-config =
    { lib, config, ... }:
    {
      options.network-config.enable = lib.mkEnableOption "system networking";
      config = lib.mkIf config.network-config.enable {
        networking.useDHCP = net.dhcp;
        networking.firewall.enable = net.firewallEnable;
        networking.firewall.allowedTCPPorts = net.firewallPorts;
        networking.wireless.enable = net.wireless;
        services.openssh.enable = net.ssh;
        services.openssh.settings.PermitRootLogin = "prohibit-password";
      };
    };
  config.flake.modules.homeManager.ssh = lib.mkIf ssh.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          compression = ssh.compression;
          serverAliveInterval = ssh.serverAliveInterval;
          serverAliveCountMax = ssh.serverAliveCountMax;
          forwardAgent = ssh.forwardAgent;
        };
      }
      // lib.mapAttrs hostToMatch hosts;
    };
  };
}
