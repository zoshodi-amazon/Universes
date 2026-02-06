# SSH Config Options
{ lib, ... }:
let
  hostType = lib.types.submodule {
    options = {
      hostname = lib.mkOption { type = lib.types.str; };
      user = lib.mkOption { type = lib.types.str; default = ""; };
      port = lib.mkOption { type = lib.types.int; default = 22; };
      identityFile = lib.mkOption { type = lib.types.str; default = ""; };
      forwardAgent = lib.mkOption { type = lib.types.bool; default = false; };
      extraOptions = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
    };
  };
in
{
  options.ssh = {
    enable = lib.mkEnableOption "SSH configuration";
    defaultPort = lib.mkOption { type = lib.types.int; default = 22; };
    compression = lib.mkOption { type = lib.types.bool; default = true; };
    serverAliveInterval = lib.mkOption { type = lib.types.int; default = 60; };
    serverAliveCountMax = lib.mkOption { type = lib.types.int; default = 3; };
    forwardAgent = lib.mkOption { type = lib.types.bool; default = false; };
    hosts = lib.mkOption { type = lib.types.attrsOf hostType; default = {}; };
  };
}
