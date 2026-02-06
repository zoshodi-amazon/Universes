{ lib, ... }:
{
  options.display = {
    enable = lib.mkEnableOption "display manager";
    backend = lib.mkOption {
      type = lib.types.enum [ "sway" "hyprland" "none" ];
      default = "none";
      description = "Window manager backend";
    };
    greeter = lib.mkOption {
      type = lib.types.enum [ "greetd" "ly" "none" ];
      default = "none";
      description = "Login greeter";
    };
  };
}
