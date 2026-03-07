# IOIdentityPhase (BEC) — nix daemon settings + secrets
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
  nix = cfg.nixSettings;
  sops = cfg.sops;
  commonNixConfig = {
    nix.settings = {
      auto-optimise-store = nix.optimise;
      max-jobs = nix.maxJobs;
      cores = nix.cores;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    nix.gc = {
      automatic = nix.gcAutomatic;
      options = "--delete-older-than ${nix.gcOlderThan}";
    };
  };
in
{
  config.flake.modules.homeManager.nix-settings =
    { config, lib, ... }:
    {
      options.nix-settings.enable = lib.mkEnableOption "Nix optimizations";
      config = lib.mkIf config.nix-settings.enable commonNixConfig;
    };
  config.flake.modules.nixos.nix-settings =
    { config, lib, ... }:
    {
      options.nix-settings.enable = lib.mkEnableOption "Nix optimizations";
      config = lib.mkIf config.nix-settings.enable (
        commonNixConfig
        // {
          nix.gc.dates = nix.gcInterval;
          nix.optimise.automatic = nix.optimise;
        }
      );
    };
  config.flake.modules.darwin.nix-settings =
    { config, lib, ... }:
    {
      options.nix-settings.enable = lib.mkEnableOption "Nix optimizations";
      config = lib.mkIf config.nix-settings.enable (
        commonNixConfig
        // {
          nix.gc.interval = {
            Weekday = 0;
            Hour = 3;
            Minute = 0;
          };
          nix.optimise.automatic = nix.optimise;
        }
      );
    };
  config.flake.modules.homeManager.secrets = lib.mkIf sops.enable {
    imports = [ inputs.sops-nix.homeManagerModules.sops ];
    sops.age.keyFile = sops.ageKeyFile;
  };
  config.flake.modules.nixos.secrets = lib.mkIf sops.enable {
    imports = [ inputs.sops-nix.nixosModules.sops ];
    sops.age.keyFile = sops.ageKeyFile;
  };
}
