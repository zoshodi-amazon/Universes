{ lib, ... }:
{
  options.scripts.scaffold = {
    enable = lib.mkEnableOption "module scaffolding";
  };
}
