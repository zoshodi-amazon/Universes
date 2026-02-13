# IOMNixBoot Monad — enables itself + disk auto-enable
{ config, lib, ... }:
let
  cfg = config.boot-config;
in
{
  config.boot-config.enable = lib.mkDefault true;
  config.boot-config.disk.enable = lib.mkDefault (cfg.disk.devices != {});
}
