# IOMNixSSH Monad — enables itself + sets host defaults
{ lib, ... }:
let
  user = "zoshodi";
  wsshProxy = "/usr/local/bin/wssh proxy %h";
  wsshProxyPort = "/usr/local/bin/wssh proxy %h --port=%p";
  wsshOpts = {
    serverAliveInterval = 15;
    serverAliveCountMax = 44;
  };
in
{
  config.ssh = {
    enable = lib.mkDefault true;
    compression = true;
    serverAliveInterval = 15;
    serverAliveCountMax = 44;
    forwardAgent = false;
    hosts = {
      "dev-dsk-*.amazon.com" = {
        hostname = "%h";
        user = user;
        extraOptions.ProxyCommand = wsshProxy;
      };
      "dev-dsk-zoshodi-2a-2931a6cf.us-west-2.amazon.com" = {
        hostname = "dev-dsk-zoshodi-2a-2931a6cf.us-west-2.amazon.com";
        user = user;
      };
      "cloud-dev" = {
        hostname = "dev-dsk-zoshodi-2a-2931a6cf.us-west-2.amazon.com";
        user = user;
      };
      "cloud-nix" = {
        hostname = "dev-dsk-zoshodi-2a-9d6f77e3.us-west-2.amazon.com";
        user = user;
      };
      "*.corp.amazon.com" = {
        hostname = "%h";
        user = user;
        extraOptions.ProxyCommand = wsshProxy;
      };
      "git.amazon.com" = {
        hostname = "git.amazon.com";
        user = user;
        extraOptions.ProxyCommand = wsshProxyPort;
      };
      "github.audible.com" = {
        hostname = "github.audible.com";
        user = "git";
        extraOptions.ProxyCommand = wsshProxyPort;
      };
    };
  };
}
