# IOPlatformPhase — boot, disk, hardware, display
{ config, lib, inputs, ... }:
let
  cfg = builtins.fromJSON (builtins.readFile ./default.json);
  boot = cfg.boot; disk = cfg.disk; hw = cfg.hardware; disp = cfg.display;
in
{
  config.flake.modules.nixos.boot-config = { pkgs, lib, config, ... }: {
    options.boot-config.enable = lib.mkEnableOption "boot configuration";
    config = lib.mkIf config.boot-config.enable {
      boot.loader.systemd-boot.enable = boot.loader == "systemd-boot";
      boot.loader.grub.enable = boot.loader == "grub";
      boot.loader.efi.canTouchEfiVariables = boot.efi;
      boot.initrd.availableKernelModules = boot.initrdModules;
      boot.kernelPackages = { default = pkgs.linuxPackages; latest = pkgs.linuxPackages_latest; lts = pkgs.linuxPackages_6_6; }.${boot.kernelPackages};
    };
  };
  config.flake.modules.nixos.disk-config = lib.mkIf disk.enable ({ pkgs, ... }: {
    imports = [ inputs.disko.nixosModules.disko ];
    disko.devices.disk = lib.mapAttrs (_: dev: {
      type = "disk"; device = dev.device;
      content = { type = dev.tableType or "gpt"; partitions = {
        ESP = { size = "512M"; content = { type = "filesystem"; format = "vfat"; mountpoint = "/boot"; }; };
      } // lib.optionalAttrs (disk.swapSize != "none") {
        swap = { size = disk.swapSize; content = { type = "swap"; randomEncryption = true; }; };
      } // {
        root = { size = "100%"; content = if disk.encryption == "luks" then { type = "luks"; name = "cryptroot"; content = { type = "filesystem"; format = disk.filesystem; mountpoint = "/"; }; } else { type = "filesystem"; format = disk.filesystem; mountpoint = "/"; }; };
      }; };
    }) disk.devices;
    boot.initrd.network = lib.mkIf disk.remoteUnlock { enable = true; ssh = { enable = true; port = 2222; hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ]; }; };
  });
  config.flake.modules.nixos.hardware-config = lib.mkIf hw.enable ({ pkgs, lib, config, ... }: {
    options.hardware-config.enable = lib.mkEnableOption "hardware configuration";
    config = lib.mkIf config.hardware-config.enable {
      hardware.enableRedistributableFirmware = hw.firmware;
      services.xserver.videoDrivers = { none = []; intel = [ "modesetting" ]; amd = [ "amdgpu" ]; nvidia = [ "nvidia" ]; apple = []; }.${hw.gpu};
      hardware.graphics.enable = hw.gpu != "none";
      services.pipewire = lib.mkIf (hw.audio == "pipewire") { enable = true; alsa.enable = true; pulse.enable = true; };
      hardware.pulseaudio.enable = hw.audio == "pulseaudio";
      hardware.bluetooth.enable = hw.bluetooth;
      services.printing.enable = hw.printing;
      services.fwupd.enable = hw.profile == "laptop" || hw.profile == "desktop";
      services.thermald.enable = hw.profile == "laptop";
      powerManagement.enable = hw.profile == "laptop";
    };
  });
  config.flake.modules.nixos.display = { lib, config, ... }: {
    options.display.enable = lib.mkEnableOption "display manager";
    config = lib.mkIf config.display.enable {
      programs.sway.enable = disp.backend == "sway";
      programs.hyprland.enable = disp.backend == "hyprland";
      services.greetd.enable = disp.greeter == "greetd";
      hardware.graphics.enable = true;
    };
  };
}
