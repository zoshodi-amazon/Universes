# IOMNixHardware — wires hardware types into NixOS modules
{ config, lib, ... }:
let
  cfg = config.hardware;
in
{
  config.flake.modules.nixos.hardware-config = lib.mkIf cfg.enable ({ pkgs, lib, config, ... }: {
    options.hardware-config.enable = lib.mkEnableOption "hardware configuration";
    config = lib.mkIf config.hardware-config.enable {
      # Firmware
      hardware.enableRedistributableFirmware = cfg.firmware;

      # GPU drivers
      services.xserver.videoDrivers = {
        none = [];
        intel = [ "modesetting" ];
        amd = [ "amdgpu" ];
        nvidia = [ "nvidia" ];
        apple = [];
      }.${cfg.gpu};

      hardware.graphics.enable = cfg.gpu != "none";

      # Audio
      services.pipewire = lib.mkIf (cfg.audio == "pipewire") {
        enable = true;
        alsa.enable = true;
        pulse.enable = true;
      };
      hardware.pulseaudio.enable = cfg.audio == "pulseaudio";

      # Bluetooth
      hardware.bluetooth.enable = cfg.bluetooth;

      # Printing
      services.printing.enable = cfg.printing;

      # Profile-specific defaults
      services.fwupd.enable = cfg.profile == "laptop" || cfg.profile == "desktop";
      services.thermald.enable = cfg.profile == "laptop";
      powerManagement.enable = cfg.profile == "laptop";
    };
  });
}
