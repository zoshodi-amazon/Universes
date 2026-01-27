# Tmux Options
{ lib, ... }:
{
  options.tmux = {
    enable = lib.mkEnableOption "tmux";
    prefix = lib.mkOption { type = lib.types.str; default = "C-a"; };
    baseIndex = lib.mkOption { type = lib.types.int; default = 1; };
    escapeTime = lib.mkOption { type = lib.types.int; default = 10; };
    historyLimit = lib.mkOption { type = lib.types.int; default = 10000; };
    mouse = lib.mkOption { type = lib.types.bool; default = true; };
    terminal = lib.mkOption { type = lib.types.str; default = "tmux-256color"; };
    extraConfig = lib.mkOption { type = lib.types.lines; default = ""; };
  };
}
