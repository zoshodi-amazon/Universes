{ config, lib, ... }:
let
  cfg = config.boot-config;
in
{
  config.flake.modules.nixos.boot-config = { pkgs, lib, config, ... }: {
    options.boot-config.enable = lib.mkEnableOption "boot configuration";
    config = lib.mkIf config.boot-config.enable {
      boot.loader.systemd-boot.enable = cfg.loader == "systemd-boot";
      boot.loader.grub.enable = cfg.loader == "grub";
      boot.loader.efi.canTouchEfiVariables = cfg.efi;
      boot.initrd.availableKernelModules = cfg.initrd.availableModules;
      boot.kernelPackages = {
        default = pkgs.linuxPackages;
        latest = pkgs.linuxPackages_latest;
        lts = pkgs.linuxPackages_6_6;
      }.${cfg.kernelPackages};
    };
  };
}
