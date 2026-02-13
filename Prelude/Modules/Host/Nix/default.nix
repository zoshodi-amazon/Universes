# Nix — global instantiation
# Exports to 3 scopes: homeManager, nixos, darwin
{ lib, config, ... }:
let
  cfg = config.nix-settings;
  commonNixConfig = {
    nix.settings = {
      auto-optimise-store = cfg.optimise;
      max-jobs = cfg.maxJobs;
      cores = cfg.cores;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    nix.gc = {
      automatic = cfg.gc.automatic;
      options = "--delete-older-than ${cfg.gc.olderThan}";
    };
  };
in
{
  flake.modules.homeManager.nix-settings = { config, lib, ... }: {
    options.nix-settings.enable = lib.mkEnableOption "Nix optimizations";
    config = lib.mkIf config.nix-settings.enable commonNixConfig;
  };

  flake.modules.nixos.nix-settings = { config, lib, ... }: {
    options.nix-settings.enable = lib.mkEnableOption "Nix optimizations";
    config = lib.mkIf config.nix-settings.enable (commonNixConfig // {
      nix.gc.dates = cfg.gc.interval;
      nix.optimise.automatic = cfg.optimise;
    });
  };

  flake.modules.darwin.nix-settings = { config, lib, ... }: {
    options.nix-settings.enable = lib.mkEnableOption "Nix optimizations";
    config = lib.mkIf config.nix-settings.enable (commonNixConfig // {
      nix.gc.interval = { Weekday = 0; Hour = 3; Minute = 0; };
      nix.optimise.automatic = cfg.optimise;
    });
  };
}