{ lib, ... }:
{
  config.tmux = {
    enable = lib.mkDefault true;
    extraConfig = "set -g allow-passthrough on";
  };
}
