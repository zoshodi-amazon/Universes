# NixSSH Artifact — typed option space for SSH configuration
{ lib, ... }:
let
  hostType = lib.types.submodule {
    options = {
      hostname = lib.mkOption { type = lib.types.str; description = "Hostname"; };
      user = lib.mkOption { type = lib.types.str; default = ""; description = "User"; };
      port = lib.mkOption { type = lib.types.int; default = 22; description = "Port"; };
      identityFile = lib.mkOption { type = lib.types.str; default = ""; description = "Identity file"; };
      forwardAgent = lib.mkOption { type = lib.types.bool; default = false; description = "Forward agent"; };
      extraOptions = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; description = "Extra options"; };
    };
  };
in
{
  options.ssh = {
    enable = lib.mkEnableOption "SSH configuration";
    defaultPort = lib.mkOption { type = lib.types.int; default = 22; description = "Default port"; };
    compression = lib.mkOption { type = lib.types.bool; default = true; description = "Compression"; };
    serverAliveInterval = lib.mkOption { type = lib.types.int; default = 60; description = "Server alive interval"; };
    serverAliveCountMax = lib.mkOption { type = lib.types.int; default = 3; description = "Server alive count max"; };
    forwardAgent = lib.mkOption { type = lib.types.bool; default = false; description = "Forward agent"; };
    hosts = lib.mkOption { type = lib.types.attrsOf hostType; default = {}; description = "Hosts"; };
  };
}
