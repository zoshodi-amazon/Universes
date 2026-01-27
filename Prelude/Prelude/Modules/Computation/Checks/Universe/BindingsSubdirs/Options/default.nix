# BindingsSubdirs check options (Invariant 5)
{ lib, ... }:
{
  options.checks.bindingsSubdirs = {
    enable = lib.mkEnableOption "Check Bindings/ subdirectories";
    allowed = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "Scripts" "Commands" "Keymaps" "Hooks" "State" "Secrets" "Plugins" ];
    };
  };
  config.checks.bindingsSubdirs.enable = lib.mkDefault true;
}
