{ lib, ... }:
{
  options.nixosSystems.desktop = {
    enable = lib.mkEnableOption "desktop environment";
    wm = lib.mkOption {
      type = lib.types.enum [ "hyprland" "sway" "gnome" "none" ];
      default = "none";
      description = "Window manager / compositor";
    };
    terminal = lib.mkOption {
      type = lib.types.enum [ "alacritty" "ghostty" "kitty" ];
      default = "alacritty";
      description = "Terminal emulator";
    };
  };
}
