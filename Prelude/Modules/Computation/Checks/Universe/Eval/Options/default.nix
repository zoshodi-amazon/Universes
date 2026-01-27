{ lib, ... }:
{
  options.checks.eval = {
    enable = lib.mkEnableOption "Eval check for homeConfigurations";
    hosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "darwin" ];
      description = "Host configurations to evaluate";
    };
  };
}
