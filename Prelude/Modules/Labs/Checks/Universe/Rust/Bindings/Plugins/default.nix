# Rust checks plugins
{ config, lib, ... }:
let cfg = config.checks.rust; in
{
  config.checks.rust.plugins = lib.mkIf cfg.enable {
    clippy = cfg.clippy.enable;
    rustfmt = cfg.rustfmt.enable;
  };
}
