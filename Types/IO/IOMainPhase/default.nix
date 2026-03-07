# IOMainPhase (QGP/Phase 7: Deploy) — entry point + deploy
# Imports phases 1-6, implements phase 7. Instantiates homeConfigurations + nixosConfigurations.
{
  config,
  lib,
  inputs,
  ...
}:
let
  base = builtins.fromJSON (builtins.readFile ./default.json);
  local =
    if builtins.pathExists ./local.json then
      builtins.fromJSON (builtins.readFile ./local.json)
    else
      { };
  cfg = lib.recursiveUpdate base local;
  hmModules = lib.attrValues config.flake.modules.homeManager;
  nixosModules = lib.attrValues config.flake.modules.nixos;
  pkgsLinux = inputs.nixpkgs.legacyPackages.x86_64-linux;
  pkgsDarwin = inputs.nixpkgs.legacyPackages.aarch64-darwin;
  corePkgsModule =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.home-manager ] ++ (map (name: pkgs.${name}) config.home.corePackages);
    };
  mkHomeConfig =
    system: target:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = if system == "darwin" then pkgsDarwin else pkgsLinux;
      modules = hmModules ++ [
        corePkgsModule
        {
          home.username = target.username;
          home.homeDirectory = target.homeDirectory;
          home.stateVersion = target.stateVersion;
        }
      ];
    };
  archToSystem = {
    x86_64 = "x86_64-linux";
    aarch64 = "aarch64-linux";
  };
  mkStandardDisko = m: {
    imports = [ inputs.disko.nixosModules.disko ];
    disko.devices.disk.main = {
      type = "disk";
      device = m.disk.device;
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "512M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
  mkNixosConfig =
    name: m:
    let
      hw =
        m.hardware or {
          enable = false;
          profile = "generic";
          gpu = "none";
          firmware = true;
          audio = "none";
          bluetooth = false;
        };
    in
    inputs.nixpkgs.lib.nixosSystem {
      system = archToSystem.${m.arch};
      specialArgs = { inherit inputs; };
      modules = [
        {
          networking.hostName = m.hostname;
          system.stateVersion = "25.05";
          security.sudo.wheelNeedsPassword = false;
          nix.settings.experimental-features = [
            "nix-command"
            "flakes"
          ];
          users.users = lib.listToAttrs (
            map (u: {
              name = u.name;
              value = {
                isNormalUser = true;
                extraGroups = u.groups;
              }
              // lib.optionalAttrs (u.initialPassword != "") {
                initialPassword = u.initialPassword;
              };
            }) m.users
          );
        }
        # Hardware profile — per-machine hardware configuration
        (lib.mkIf (hw.enable or false) {
          hardware.enableRedistributableFirmware = hw.firmware or true;
          services.xserver.videoDrivers =
            {
              none = [ ];
              intel = [ "modesetting" ];
              amd = [ "amdgpu" ];
              nvidia = [ "nvidia" ];
              apple = [ ];
            }
            .${hw.gpu or "none"};
          hardware.graphics.enable = (hw.gpu or "none") != "none";
          services.pipewire = lib.mkIf ((hw.audio or "none") == "pipewire") {
            enable = true;
            alsa.enable = true;
            pulse.enable = true;
          };
          hardware.pulseaudio.enable = (hw.audio or "none") == "pulseaudio";
          hardware.bluetooth.enable = hw.bluetooth or false;
          services.fwupd.enable =
            (hw.profile or "generic") == "laptop" || (hw.profile or "generic") == "desktop";
          services.thermald.enable = (hw.profile or "generic") == "laptop";
          powerManagement.enable = (hw.profile or "generic") == "laptop";
        })
      ]
      ++ lib.optionals (m.format == "iso") [
        "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      ]
      ++ lib.optionals (m.disk.layout == "standard") [ (mkStandardDisko m) ]
      ++ nixosModules
      ++ lib.optionals (m.format == "microvm") [
        inputs.microvm.nixosModules.microvm
        {
          microvm = {
            hypervisor = cfg.microvm.hypervisor;
            mem = cfg.microvm.mem;
            vcpu = cfg.microvm.vcpu;
            cpu = "max";
            interfaces = [
              {
                type = "user";
                id = "usernet";
                mac = "02:00:00:00:00:01";
              }
            ];
            forwardPorts = [
              {
                from = "host";
                host.port = 2222;
                guest.port = 22;
              }
            ];
            shares = [
              {
                tag = "ro-store";
                source = "/nix/store";
                mountPoint = "/nix/.ro-store";
              }
            ];
          };
          services.openssh.enable = true;
          services.openssh.settings.PermitRootLogin = "yes";
          users.users.root.initialPassword = "root";
        }
      ]
      ++ lib.optionals (m.persistence.strategy == "impermanent") [
        inputs.impermanence.nixosModules.impermanence
        {
          fileSystems."/" = {
            device = "none";
            fsType = "tmpfs";
            options = [
              "defaults"
              "size=2G"
              "mode=755"
            ];
          };
          fileSystems."/persistent" = lib.mkIf (m.persistence.device != "") {
            device = m.persistence.device;
            fsType = "ext4";
            neededForBoot = true;
          };
          environment.persistence."/persistent" = {
            hideMounts = true;
            directories =
              m.persistence.paths
              ++ (map (u: {
                directory = "/home/${u.name}";
                user = u.name;
                group = "users";
              }) m.users);
            files = [ "/etc/machine-id" ];
          };
        }
      ];
    };
in
{
  imports = [
    ../IOIdentityPhase
    ../IOPlatformPhase
    ../IONetworkPhase
    ../IOServicesPhase
    ../IOUserPhase
    ../IOWorkspacePhase
  ];

  options.flake.modules = {
    homeManager = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = { };
      description = "Home Manager modules";
    };
    nixos = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = { };
      description = "NixOS modules";
    };
    darwin = lib.mkOption {
      type = lib.types.attrsOf lib.types.deferredModule;
      default = { };
      description = "Darwin modules";
    };
  };
  options.home.corePackages = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    description = "Core packages for all home configurations";
  };

  config.systems = [
    "x86_64-linux"
    "aarch64-linux"
    "x86_64-darwin"
    "aarch64-darwin"
  ];

  config.flake.homeConfigurations =
    (lib.optionalAttrs cfg.home.darwin.enable { darwin = mkHomeConfig "darwin" cfg.home.darwin; })
    // (lib.optionalAttrs cfg.home.cloudDev.enable {
      cloud-dev = mkHomeConfig "linux" cfg.home.cloudDev;
    })
    // (lib.optionalAttrs cfg.home.cloudNix.enable {
      cloud-nix = mkHomeConfig "linux" cfg.home.cloudNix;
    })
    // (lib.optionalAttrs (cfg.home.nixos.enable or false) {
      nixos = mkHomeConfig "linux" cfg.home.nixos;
    });

  config.flake.nixosConfigurations = lib.mapAttrs mkNixosConfig cfg.machines;

  config.perSystem =
    { system, pkgs, ... }:
    lib.mkIf (system == "x86_64-linux" || system == "aarch64-linux") {
      packages =
        let
          formatPkgs = lib.flatten (
            lib.mapAttrsToList (
              name: m:
              lib.optionals (m.format == "iso") [
                {
                  name = "${name}-iso";
                  value = config.flake.nixosConfigurations.${name}.config.system.build.isoImage;
                }
              ]
              ++ [
                {
                  name = "${name}-vm";
                  value = config.flake.nixosConfigurations.${name}.config.system.build.vm;
                }
              ]
            ) cfg.machines
          );
          ociPkgs = lib.mapAttrsToList (name: m: {
            name = "${name}-oci";
            value = pkgs.dockerTools.buildLayeredImage {
              name = name;
              tag = "latest";
              contents = [ config.flake.nixosConfigurations.${name}.config.system.build.toplevel ];
              config = {
                Cmd = [ "${config.flake.nixosConfigurations.${name}.config.system.build.toplevel}/init" ];
              };
            };
          }) cfg.machines;
          microvmPkgs = lib.mapAttrsToList (name: m: {
            name = "${name}-microvm";
            value = config.flake.nixosConfigurations.${name}.config.microvm.declaredRunner or pkgs.hello;
          }) (lib.filterAttrs (_: m: m.format == "microvm") cfg.machines);
        in
        lib.listToAttrs (formatPkgs ++ ociPkgs ++ microvmPkgs);
    };
}
