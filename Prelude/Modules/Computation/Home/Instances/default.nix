# Home Instances - creates homeConfigurations by consuming flake.modules.homeManager.*
{ config, lib, inputs, ... }:
let
  hmModules = lib.attrValues config.flake.modules.homeManager;
  corePkgNames = config.home.corePackages;
  darwin = config.home.darwin;
  cloudDev = config.home.cloudDev;
  cloudNix = config.home.cloudNix;
  pkgsLinux = inputs.nixpkgs.legacyPackages.x86_64-linux;
  pkgsDarwin = inputs.nixpkgs.legacyPackages.aarch64-darwin;
  
  # Module that adds core packages using the pkgs from homeManagerConfiguration
  corePkgsModule = { pkgs, ... }: {
    home.packages = [ pkgs.home-manager ] ++ (map (name: pkgs.${name}) corePkgNames);
  };
in
{
  config.flake.homeConfigurations = 
    (lib.optionalAttrs darwin.enable {
      darwin = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsDarwin;
        modules = hmModules ++ [ corePkgsModule {
          home.username = darwin.username;
          home.homeDirectory = darwin.homeDirectory;
          home.stateVersion = darwin.stateVersion;
        }];
      };
    })
    //
    (lib.optionalAttrs cloudDev.enable {
      cloud-dev = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsLinux;
        modules = hmModules ++ [ corePkgsModule {
          home.username = cloudDev.username;
          home.homeDirectory = cloudDev.homeDirectory;
          home.stateVersion = cloudDev.stateVersion;
        }];
      };
    })
    //
    (lib.optionalAttrs cloudNix.enable {
      cloud-nix = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsLinux;
        modules = hmModules ++ [ corePkgsModule {
          home.username = cloudNix.username;
          home.homeDirectory = cloudNix.homeDirectory;
          home.stateVersion = cloudNix.stateVersion;
        }];
      };
    });
}
