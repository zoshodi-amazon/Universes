# Systems Instances - MicroVM via nixos-generators
{ config, lib, inputs, ... }:
let
  microvm = config.nixosSystems.microvm;
  nixosModules = lib.attrValues config.flake.modules.nixos;
in
{
  config = lib.mkIf microvm.enable {
    perSystem = { pkgs, system, ... }: lib.mkIf (system == "x86_64-linux" || system == "aarch64-linux") {
      packages.microvm = inputs.nixos-generators.nixosGenerate {
        inherit pkgs;
        format = "vm";
        modules = [
          {
            virtualisation.memorySize = microvm.memory;
            virtualisation.cores = microvm.vcpu;
            virtualisation.graphics = false;
            users.users.test = {
              isNormalUser = true;
              password = "test";
              extraGroups = [ "wheel" ];
            };
            services.getty.autologinUser = "test";
            system.stateVersion = "24.05";
          }
        ] ++ microvm.modules ++ nixosModules;
      };
    };
  };
}
