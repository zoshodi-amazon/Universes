# NixTmux Artifact
{ lib, ... }:
{
  options.tmux = {
    enable = lib.mkEnableOption "tmux";
    prefix = lib.mkOption { type = lib.types.str; default = "C-a"; description = "Prefix"; };
    baseIndex = lib.mkOption { type = lib.types.int; default = 1; description = "Base index"; };
    escapeTime = lib.mkOption { type = lib.types.int; default = 10; description = "Escape time"; };
    historyLimit = lib.mkOption { type = lib.types.int; default = 10000; description = "History limit"; };
    mouse = lib.mkOption { type = lib.types.bool; default = true; description = "Mouse"; };
    terminal = lib.mkOption { type = lib.types.str; default = "tmux-256color"; description = "Terminal"; };
    extraConfig = lib.mkOption { type = lib.types.lines; default = ""; description = "Extra config"; };
  };
}
