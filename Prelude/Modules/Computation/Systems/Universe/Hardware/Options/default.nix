{ lib, ... }:
{
  options.nixosSystems.hardware = {
    target = lib.mkOption {
      type = lib.types.enum [ "x86_64" "rpi4" "rpi5" ];
      default = "x86_64";
      description = "Hardware target";
    };
    format = lib.mkOption {
      type = lib.types.enum [ "iso" "raw-efi" "sd-card" "qcow" "vm" ];
      default = "vm";
      description = "Image format";
    };
  };
}
