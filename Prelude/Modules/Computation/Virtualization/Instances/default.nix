# Instances: exports to flake.modules for virtualization
{ config, lib, ... }:
let
  microvm = config.virtualization.microvm;
  lima = config.virtualization.lima;
in
{
  config.flake.modules.nixos.microvm = lib.mkIf microvm.enable {
    # MicroVM host configuration
  };

  config.flake.modules.homeManager.lima = lib.mkIf lima.enable ({ pkgs, ... }: {
    home.packages = lib.mkIf pkgs.stdenv.isDarwin [ pkgs.lima ];
    
    home.file.".lima/_config/default.yaml".text = builtins.toJSON {
      vmType = lima.vmType;
      cpus = lima.cpus;
      memory = lima.memory;
      disk = lima.disk;
      mounts = lib.optional lima.mountHome { location = "~"; writable = true; };
      provision = [{ mode = "system"; script = "curl -L https://nixos.org/nix/install | sh -s -- --daemon"; }];
    };
  });
}
