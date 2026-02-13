# SSH — global instantiation
{ config, lib, ... }:
let
  cfg = config.ssh;
  hostToMatch = name: host: {
    inherit (host) hostname;
    user = lib.mkIf (host.user != "") host.user;
    port = host.port;
    identityFile = lib.mkIf (host.identityFile != "") host.identityFile;
    forwardAgent = host.forwardAgent;
    extraOptions = host.extraOptions;
  };
in
{
  config.flake.modules.homeManager.ssh = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      matchBlocks."*" = {
        compression = cfg.compression;
        serverAliveInterval = cfg.serverAliveInterval;
        serverAliveCountMax = cfg.serverAliveCountMax;
        forwardAgent = cfg.forwardAgent;
      };
    } // { matchBlocks = lib.mapAttrs hostToMatch cfg.hosts; };
  };
}
