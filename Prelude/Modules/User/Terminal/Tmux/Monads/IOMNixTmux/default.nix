# IOMNixTmux Monad — enables itself + passthrough
{ lib, ... }:
{
  config.tmux = {
    enable = lib.mkDefault true;
    extraConfig = "set -g allow-passthrough on";
  };
}
