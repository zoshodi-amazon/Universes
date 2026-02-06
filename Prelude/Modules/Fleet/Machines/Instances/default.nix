# Machines Instances - Wire to nixosConfigurations with multiple output formats
{ config, lib, inputs, ... }:
let
  machines = config.machines;
  stateVersion = "25.05";
  
  archToSystem = {
    x86_64 = "x86_64-linux";
    aarch64 = "aarch64-linux";
  };
  
  nixosModules = lib.attrValues config.flake.modules.nixos;

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
    ]
    ++ lib.optionals (cfg.format.type != "microvm") [
      "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
    ]
    ++ nixosModules
    ++ lib.optionals (cfg.format.type == "microvm") [
      inputs.microvm.nixosModules.microvm
      {
        microvm = {
          hypervisor = config.microvm-config.hypervisor;
          mem = config.microvm-config.mem;
          vcpu = config.microvm-config.vcpu;
          cpu = "max";
          interfaces = [{
            type = "user";
            id = "usernet";
            mac = "02:00:00:00:00:01";
          }];
          forwardPorts = [{
            from = "host";
            host.port = 2222;
            guest.port = 22;
          }];
          shares = [{
            tag = "ro-store";
            source = "/nix/store";
            mountPoint = "/nix/.ro-store";
          }];
        };
        services.openssh.enable = true;
        services.openssh.settings.PermitRootLogin = "yes";
        users.users.root.initialPassword = "root";
      }
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
      
      # MicroVM runner
      microvmPackages = lib.mapAttrsToList (name: cfg: {
        name = "${name}-microvm";
        value = config.flake.nixosConfigurations.${name}.config.microvm.declaredRunner or pkgs.hello;
      }) (lib.filterAttrs (n: c: c.format.type == "microvm") machines);
    in
    lib.listToAttrs (formatPackages ++ ociPackages ++ microvmPackages);
  };
}
