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
  getPkgs = pkgs: map (name: pkgs.${name}) corePkgNames;
in
{
  config.flake.homeConfigurations = 
    (lib.optionalAttrs darwin.enable {
      darwin = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsDarwin;
        modules = hmModules ++ [{
          home.username = darwin.username;
          home.homeDirectory = darwin.homeDirectory;
          home.stateVersion = darwin.stateVersion;
          home.packages = [ pkgsDarwin.home-manager ] ++ (getPkgs pkgsDarwin);
        }];
      };
    })
    //
    (lib.optionalAttrs cloudDev.enable {
      cloud-dev = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsLinux;
        modules = hmModules ++ [{
          home.username = cloudDev.username;
          home.homeDirectory = cloudDev.homeDirectory;
          home.stateVersion = cloudDev.stateVersion;
          home.packages = [ pkgsLinux.home-manager ] ++ (getPkgs pkgsLinux);
        }];
      };
    })
    //
    (lib.optionalAttrs cloudNix.enable {
      cloud-nix = inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsLinux;
        modules = hmModules ++ [{
          home.username = cloudNix.username;
          home.homeDirectory = cloudNix.homeDirectory;
          home.stateVersion = cloudNix.stateVersion;
          home.packages = [ pkgsLinux.home-manager ] ++ (getPkgs pkgsLinux);
        }];
      };
    });
}
