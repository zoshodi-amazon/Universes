{ lib, ... }:
{
  options.scripts.deploy = {
    enable = lib.mkEnableOption "deployment scripts";
  };
}
