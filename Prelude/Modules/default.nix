# Modules tensor + flake.modules option declaration
{ lib, ... }:
{
  # Declare flake.modules option for homeManager/nixos/darwin exports
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

  # Define systems for perSystem
  config.systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
}
