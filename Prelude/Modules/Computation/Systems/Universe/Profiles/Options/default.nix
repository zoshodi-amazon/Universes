{ lib, ... }:
{
  options.nixosSystems.profile = lib.mkOption {
    type = lib.types.enum [ "workstation" "headless" "minimal" "sovereignty" ];
    default = "minimal";
    description = "System profile type";
  };
}
