# Machines Instances - Wire to Clan and nixosConfigurations
{ config, lib, inputs, ... }:
let
  machines = config.machines;
  
  archToSystem = {
    x86_64 = "x86_64-linux";
    aarch64 = "aarch64-linux";
  };
  
  formatToOutput = {
    iso = "isoImage";
    vm = "vm";
    sd-image = "sdImage";
    raw-efi = "raw-efi";
  };
  
  mkNixosConfig = name: cfg: inputs.nixpkgs.lib.nixosSystem {
    system = archToSystem.${cfg.target.arch};
    specialArgs = { inherit inputs; };
    modules = [
      # Core
      {
        networking.hostName = cfg.identity.hostname;
        system.stateVersion = "24.11";
        security.sudo.wheelNeedsPassword = false;
        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        
        # Users - each maps to a homeConfiguration
        users.users = lib.listToAttrs (map (u: {
          name = u.name;
          value = {
            isNormalUser = true;
            extraGroups = u.groups;
            initialPassword = u.initialPassword;
          };
        }) cfg.users);
      }
      # ISO bootable
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ] 
    # Impermanence modules (conditionally added)
    ++ lib.optionals (cfg.persistence.strategy == "impermanent") [
      inputs.impermanence.nixosModules.impermanence
      {
        fileSystems."/" = {
          device = "none";
          fsType = "tmpfs";
          options = [ "defaults" "size=2G" "mode=755" ];
        };
        
        fileSystems."/persistent" = lib.mkIf (cfg.persistence.device != null) {
          device = cfg.persistence.device;
          fsType = "ext4";
          neededForBoot = true;
        };
        
        environment.persistence."/persistent" = {
          hideMounts = true;
          directories = cfg.persistence.paths ++ (map (u: {
            directory = "/home/${u.name}";
            user = u.name;
            group = "users";
          }) cfg.users);
          files = [ "/etc/machine-id" ];
        };
      }
    ];
  };
in
{
  config.flake.nixosConfigurations = lib.mapAttrs mkNixosConfig machines;
  
  config.perSystem = { system, pkgs, ... }: lib.mkIf (system == "x86_64-linux" || system == "aarch64-linux") {
    packages = lib.mapAttrs' (name: cfg: 
      lib.nameValuePair "${name}-${cfg.format.type}" 
        config.flake.nixosConfigurations.${name}.config.system.build.${formatToOutput.${cfg.format.type}}
    ) machines;
  };
}
