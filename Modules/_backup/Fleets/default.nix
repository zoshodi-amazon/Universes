# Fleets — option declarations + systems for instantiation layer
{ lib, ... }:
{
  options.flake.modules = {
    homeManager = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = {};
      description = "Home Manager modules to export";
    };
    nixos = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = {};
      description = "NixOS modules to export";
    };
    darwin = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = {};
      description = "Darwin modules to export";
    };
  };

  config.systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
}
