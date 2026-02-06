# Deploy Instances - deploy-rs integration
{ config, lib, inputs, ... }:
let
  cfg = config.deploy;
in
{
  config = lib.mkIf cfg.enable {
    flake.deploy.nodes = lib.mapAttrs (name: node: {
      hostname = node.hostname;
      sshUser = cfg.sshUser;
      profiles = lib.mapAttrs (pname: profile: {
        user = profile.user;
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos 
          config.flake.nixosConfigurations.${profile.path};
      }) node.profiles;
    }) cfg.nodes;

    perSystem = { pkgs, system, ... }: {
      checks.deploy = inputs.deploy-rs.lib.${system}.deployChecks config.flake.deploy;
    };
  };
}
