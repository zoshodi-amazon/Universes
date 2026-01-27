# ModuleDirs check options (Invariant 2)
{ lib, ... }:
{
  options.checks.moduleDirs = {
    enable = lib.mkEnableOption "Check Module directory structure";
    required = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "README.md" "default.nix" "Env" "Instances" "Universe" ];
    };
  };
  config.checks.moduleDirs.enable = lib.mkDefault true;
}
