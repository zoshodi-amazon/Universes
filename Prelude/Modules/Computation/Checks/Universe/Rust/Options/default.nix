# Rust checks options
{ lib, ... }:
{
  options.checks.rust = {
    enable = lib.mkEnableOption "Rust linting";
    clippy.enable = lib.mkOption { type = lib.types.bool; default = true; };
    rustfmt.enable = lib.mkOption { type = lib.types.bool; default = true; };
    plugins = lib.mkOption { type = lib.types.attrsOf lib.types.bool; default = {}; };
  };
}
