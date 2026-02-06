# Machines Instances - Wire to nixosConfigurations with multiple output formats
{ config, lib, inputs, ... }:
let
  machines = config.machines;
  stateVersion = "25.05";
  
  archToSystem = {
    x86_64 = "x86_64-linux";
    aarch64 = "aarch64-linux";
  };
  
  mkNixosConfig = name: cfg: inputs.nixpkgs.lib.nixosSystem {
    system = archToSystem.${cfg.target.arch};
    specialArgs = { inherit inputs; };
    modules = [
      {
        networking.hostName = cfg.identity.hostname;
        system.stateVersion = stateVersion;
        security.sudo.wheelNeedsPassword = false;
        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        users.users = lib.listToAttrs (map (u: {
          name = u.name;
          value = {
            isNormalUser = true;
            extraGroups = u.groups;
            initialPassword = u.initialPassword;
          };
        }) cfg.users);
      }
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ] 
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
    packages = let
      # Standard formats from system.build
      formatPackages = lib.flatten (lib.mapAttrsToList (name: cfg: [
        { name = "${name}-iso"; value = config.flake.nixosConfigurations.${name}.config.system.build.isoImage; }
        { name = "${name}-vm"; value = config.flake.nixosConfigurations.${name}.config.system.build.vm; }
      ]) machines);
      
      # OCI/Docker image via dockerTools
      ociPackages = lib.mapAttrsToList (name: cfg: {
        name = "${name}-oci";
        value = pkgs.dockerTools.buildLayeredImage {
          name = name;
          tag = "latest";
          contents = [ config.flake.nixosConfigurations.${name}.config.system.build.toplevel ];
          config = {
            Cmd = [ "${config.flake.nixosConfigurations.${name}.config.system.build.toplevel}/init" ];
          };
        };
      }) machines;
    in
    lib.listToAttrs (formatPackages ++ ociPackages);
  };
}
