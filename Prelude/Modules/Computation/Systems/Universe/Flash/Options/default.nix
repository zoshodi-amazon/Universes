{ lib, ... }:
{
  options.nixosSystems.flash.enable = lib.mkEnableOption "flash script" // { default = true; };
}
