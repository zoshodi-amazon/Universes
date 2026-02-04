# Systems Instances - NixOS configurations and bootable images
{ config, lib, inputs, ... }:
let
  cfg = config.nixosSystems;
  
  # Map our target names to nixpkgs system strings
  targetToSystem = {
    x86_64 = "x86_64-linux";
    rpi4 = "aarch64-linux";
    rpi5 = "aarch64-linux";
  };
  
  # Hardware-specific NixOS modules
  hardwareModule = target: { modulesPath, ... }: {
    imports = lib.optionals (target == "rpi4" || target == "rpi5") [
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ];
    
    # x86_64 bootloader
    boot.loader.systemd-boot.enable = lib.mkIf (target == "x86_64") true;
    boot.loader.efi.canTouchEfiVariables = lib.mkIf (target == "x86_64") true;
    
    # RPi kernel
    boot.kernelPackages = lib.mkIf (target == "rpi4") (lib.mkDefault inputs.nixpkgs.legacyPackages.aarch64-linux.linuxPackages_rpi4);
  };
  
  # Profile-specific packages and services
  profileModule = profile: { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      vim git curl
    ] ++ lib.optionals (profile == "workstation" || profile == "sovereignty") [
      htop tmux
    ];
    
    services.openssh = lib.mkIf (profile != "minimal") {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.PermitRootLogin = "no";
    };
  };
  
  # Desktop module
  desktopModule = { pkgs, ... }: lib.mkIf cfg.desktop.enable {
    services.xserver.enable = cfg.desktop.wm == "gnome";
    services.xserver.desktopManager.gnome.enable = cfg.desktop.wm == "gnome";
    
    programs.hyprland.enable = cfg.desktop.wm == "hyprland";
    programs.sway.enable = cfg.desktop.wm == "sway";
    
    environment.systemPackages = [
      (lib.getAttr cfg.desktop.terminal {
        alacritty = pkgs.alacritty;
        ghostty = pkgs.ghostty or pkgs.alacritty;
        kitty = pkgs.kitty;
      })
    ];
  };
  
  # Impermanence module - only include import when enabled
  impermanenceModule = { lib, ... }: {
    imports = lib.optionals cfg.impermanence.enable [
      inputs.impermanence.nixosModules.impermanence
    ];
    
    fileSystems."/" = lib.mkIf (cfg.impermanence.enable && cfg.impermanence.strategy == "tmpfs") {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=2G" "mode=755" ];
    };
    
    environment.persistence = lib.mkIf cfg.impermanence.enable {
      ${cfg.impermanence.persistPath} = {
        hideMounts = true;
        directories = cfg.impermanence.directories;
        files = cfg.impermanence.files;
        users.${cfg.core.username} = {
          directories = [ "Documents" "Downloads" ".ssh" ".gnupg" ];
        };
      };
    };
  };
  
  # Core system module
  coreModule = { ... }: {
    networking.hostName = cfg.core.hostname;
    time.timeZone = cfg.core.timezone;
    i18n.defaultLocale = cfg.core.locale;
    system.stateVersion = cfg.core.stateVersion;
    
    networking.firewall.enable = cfg.core.networking.firewall;
    networking.networkmanager.enable = cfg.core.networking.networkManager;
    
    users.users.${cfg.core.username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      initialPassword = "changeme";
    };
    
    security.sudo.wheelNeedsPassword = false;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
  };
  
  # Build a NixOS configuration for a given profile/target combo
  mkSystem = { profile, target }: 
    let
      system = targetToSystem.${target};
    in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        coreModule
        (hardwareModule target)
        (profileModule profile)
        desktopModule
        impermanenceModule
        { nixosSystems.profile = profile; nixosSystems.hardware.target = target; }
      ];
    };
    
  # Only build for Linux systems
  linuxOnly = system: lib.elem system [ "x86_64-linux" "aarch64-linux" ];
in
{
  # Export nixosConfigurations for each profile/target combo
  config.flake.nixosConfigurations = {
    "minimal-x86_64" = mkSystem { profile = "minimal"; target = "x86_64"; };
    "headless-x86_64" = mkSystem { profile = "headless"; target = "x86_64"; };
    "workstation-x86_64" = mkSystem { profile = "workstation"; target = "x86_64"; };
    "sovereignty-x86_64" = mkSystem { profile = "sovereignty"; target = "x86_64"; };
    "minimal-rpi4" = mkSystem { profile = "minimal"; target = "rpi4"; };
    "headless-rpi4" = mkSystem { profile = "headless"; target = "rpi4"; };
  };
  
  # Export image packages
  config.perSystem = { system, pkgs, ... }: lib.mkIf (linuxOnly system) {
    packages = {
      # VM images (quick testing)
      "minimal-vm" = config.flake.nixosConfigurations."minimal-x86_64".config.system.build.vm;
      "headless-vm" = config.flake.nixosConfigurations."headless-x86_64".config.system.build.vm;
      "workstation-vm" = config.flake.nixosConfigurations."workstation-x86_64".config.system.build.vm;
      
      # ISO images
      "minimal-iso" = config.flake.nixosConfigurations."minimal-x86_64".config.system.build.isoImage or null;
      
      # Flash script
      flash = pkgs.writeScriptBin "flash" ''
        #!${pkgs.nushell}/bin/nu
        ${builtins.readFile ../Universe/Flash/Bindings/Scripts/default.nu}
      '';
    };
  };
}
