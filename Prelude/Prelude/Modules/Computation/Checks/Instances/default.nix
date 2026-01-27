# Instances: exports to perSystem.checks and devShells
{ config, lib, ... }:
let
  nix = config.checks.nix;
  python = config.checks.python;
  rust = config.checks.rust;
  eval = config.checks.eval;
  moduleDirs = config.checks.moduleDirs;
  universeFeatures = config.checks.universeFeatures;
  bindingsSubdirs = config.checks.bindingsSubdirs;
  noManualImports = config.checks.noManualImports;
  homeConfigs = config.flake.homeConfigurations;
  checksDir = ../Universe;
  modulesDir = ../../..;
in
{
  config.perSystem = { pkgs, ... }: {
    devShells.checks = pkgs.mkShell {
      packages = lib.flatten [
        (lib.optionals nix.enable [
          (lib.optional nix.nixfmt.enable pkgs.nixfmt-rfc-style)
          (lib.optional nix.deadnix.enable pkgs.deadnix)
          (lib.optional nix.statix.enable pkgs.statix)
        ])
        (lib.optionals python.enable [
          (lib.optional python.ruff.enable pkgs.ruff)
          (lib.optional python.black.enable pkgs.black)
        ])
        (lib.optionals rust.enable [
          (lib.optional rust.clippy.enable pkgs.clippy)
          (lib.optional rust.rustfmt.enable pkgs.rustfmt)
        ])
      ];
    };

    checks = lib.mkMerge [
      (lib.mkIf eval.enable {
        eval-home = pkgs.runCommand "eval-home" {} ''
          echo "Evaluating homeConfigurations..."
          ${lib.concatMapStringsSep "\n" (host:
            if homeConfigs ? ${host}
            then "echo '✓ ${host}: ${homeConfigs.${host}.activationPackage}'"
            else "echo '✗ ${host}: not found' && exit 1"
          ) eval.hosts}
          touch $out
        '';
      })

      (lib.mkIf moduleDirs.enable {
        invariant-module-dirs = pkgs.runCommand "invariant-module-dirs" {
          nativeBuildInputs = [ pkgs.nushell ];
        } ''
          cd ${modulesDir}
          MODULES_ROOT=. nu ${checksDir}/ModuleDirs/Bindings/Scripts/default.nu
          touch $out
        '';
      })

      (lib.mkIf universeFeatures.enable {
        invariant-universe-features = pkgs.runCommand "invariant-universe-features" {
          nativeBuildInputs = [ pkgs.nushell ];
        } ''
          cd ${modulesDir}
          MODULES_ROOT=. nu ${checksDir}/UniverseFeatures/Bindings/Scripts/default.nu
          touch $out
        '';
      })

      (lib.mkIf bindingsSubdirs.enable {
        invariant-bindings-subdirs = pkgs.runCommand "invariant-bindings-subdirs" {
          nativeBuildInputs = [ pkgs.nushell ];
        } ''
          cd ${modulesDir}
          MODULES_ROOT=. nu ${checksDir}/BindingsSubdirs/Bindings/Scripts/default.nu
          touch $out
        '';
      })

      (lib.mkIf noManualImports.enable {
        invariant-no-manual-imports = pkgs.runCommand "invariant-no-manual-imports" {
          nativeBuildInputs = [ pkgs.nushell ];
        } ''
          cd ${modulesDir}
          MODULES_ROOT=. nu ${checksDir}/NoManualImports/Bindings/Scripts/default.nu
          touch $out
        '';
      })
    ];
  };
}
