# NoManualImports check options (Invariant 11)
{ lib, ... }:
{
  options.checks.noManualImports = {
    enable = lib.mkEnableOption "Check for manual imports in .nix files";
    pattern = lib.mkOption {
      type = lib.types.str;
      default = "imports\\s*=\\s*\\[";
    };
    allowedFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "Instances/default.nix" ];
      description = "Files allowed to have imports (e.g., for external modules)";
    };
  };
  config.checks.noManualImports.enable = lib.mkDefault true;
}
