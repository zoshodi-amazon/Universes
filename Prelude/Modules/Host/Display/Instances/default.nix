{ config, lib, ... }:
let
  cfg = config.display;
in
{
  config.flake.modules.nixos.display = { lib, config, ... }: {
    options.display.enable = lib.mkEnableOption "display manager";
    config = lib.mkIf config.display.enable {
      programs.sway.enable = cfg.backend == "sway";
      programs.hyprland.enable = cfg.backend == "hyprland";
      services.greetd.enable = cfg.greeter == "greetd";
      hardware.graphics.enable = true;
    };
  };
}
