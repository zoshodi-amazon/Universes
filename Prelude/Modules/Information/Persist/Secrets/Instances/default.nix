# Secrets Instances - sops-nix modules
{ config, lib, inputs, ... }:
let
  sops = config.secrets.sops;
in
{
  config = lib.mkIf sops.enable {
    flake.modules.homeManager.secrets = {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];
      sops.age.keyFile = sops.ageKeyFile;
    };

    flake.modules.nixos.secrets = {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops.age.keyFile = sops.ageKeyFile;
    };
  };
}
