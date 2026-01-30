{ lib, config, ... }:
let
  cfg = config.nix-settings;
in
{
  flake.modules.homeManager.nix-settings = { config, lib, ... }: {
    options.nix-settings.enable = lib.mkEnableOption "Nix optimizations";
    config = lib.mkIf config.nix-settings.enable {
      nix = {
        settings = {
          auto-optimise-store = cfg.optimise;
          max-jobs = cfg.maxJobs;
          cores = cfg.cores;
          experimental-features = [ "nix-command" "flakes" ];
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
        gc = {
          automatic = cfg.gc.automatic;
          options = "--delete-older-than ${cfg.gc.olderThan}";
        };
      };
    };
  };

  flake.modules.nixos.nix-settings = { config, lib, ... }: {
    options.nix-settings.enable = lib.mkEnableOption "Nix optimizations";
    config = lib.mkIf config.nix-settings.enable {
      nix = {
        settings = {
          auto-optimise-store = cfg.optimise;
          max-jobs = cfg.maxJobs;
          cores = cfg.cores;
          experimental-features = [ "nix-command" "flakes" ];
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
        gc = {
          automatic = cfg.gc.automatic;
          dates = cfg.gc.interval;
          options = "--delete-older-than ${cfg.gc.olderThan}";
        };
        optimise.automatic = cfg.optimise;
      };
    };
  };

  flake.modules.darwin.nix-settings = { config, lib, ... }: {
    options.nix-settings.enable = lib.mkEnableOption "Nix optimizations";
    config = lib.mkIf config.nix-settings.enable {
      nix = {
        settings = {
          auto-optimise-store = cfg.optimise;
          max-jobs = cfg.maxJobs;
          cores = cfg.cores;
          experimental-features = [ "nix-command" "flakes" ];
          substituters = [
            "https://cache.nixos.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };
        gc = {
          automatic = cfg.gc.automatic;
          interval = { Weekday = 0; Hour = 3; Minute = 0; };
          options = "--delete-older-than ${cfg.gc.olderThan}";
        };
        optimise.automatic = cfg.optimise;
      };
    };
  };
}
