# NixHardware — typed option space for hardware profile detection
{ lib, ... }:
{
  options.hardware = {
    enable = lib.mkEnableOption "Hardware profile configuration";
    profile = lib.mkOption {
      type = lib.types.enum [ "generic" "laptop" "desktop" "server" "vm" "rpi" ];
      default = "generic";
      description = "Hardware profile class";
    };
    gpu = lib.mkOption {
      type = lib.types.enum [ "none" "intel" "amd" "nvidia" "apple" ];
      default = "none";
      description = "GPU vendor for driver selection";
    };
    firmware = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable non-free firmware blobs";
    };
    audio = lib.mkOption {
      type = lib.types.enum [ "none" "pipewire" "pulseaudio" ];
      default = "none";
      description = "Audio subsystem";
    };
    bluetooth = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Bluetooth support";
    };
    printing = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable CUPS printing";
    };
  };
}
