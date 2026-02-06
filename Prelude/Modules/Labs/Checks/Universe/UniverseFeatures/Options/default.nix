# UniverseFeatures check options (Invariant 3)
{ lib, ... }:
{
  options.checks.universeFeatures = {
    enable = lib.mkEnableOption "Check Universe/<Feature> structure";
    required = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "Options" "Bindings" ];
    };
  };
  config.checks.universeFeatures.enable = lib.mkDefault true;
}
