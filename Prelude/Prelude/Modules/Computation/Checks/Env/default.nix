# Env: aggregates Universe/*/Options → ENV vars
{ config, lib, ... }:
let
  nix = config.checks.nix;
  python = config.checks.python;
  rust = config.checks.rust;
in
{
  options.checks.env = lib.mkOption { type = lib.types.attrsOf lib.types.str; default = {}; };
  config.checks.env = {
    CHECKS_NIX = lib.boolToString nix.enable;
    CHECKS_NIX_NIXFMT = lib.boolToString nix.nixfmt.enable;
    CHECKS_NIX_DEADNIX = lib.boolToString nix.deadnix.enable;
    CHECKS_NIX_STATIX = lib.boolToString nix.statix.enable;
    CHECKS_PYTHON = lib.boolToString python.enable;
    CHECKS_PYTHON_RUFF = lib.boolToString python.ruff.enable;
    CHECKS_PYTHON_BLACK = lib.boolToString python.black.enable;
    CHECKS_RUST = lib.boolToString rust.enable;
    CHECKS_RUST_CLIPPY = lib.boolToString rust.clippy.enable;
    CHECKS_RUST_RUSTFMT = lib.boolToString rust.rustfmt.enable;
  };
}
