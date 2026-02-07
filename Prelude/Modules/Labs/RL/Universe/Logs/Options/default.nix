# Logs Options - OTEL structured logging
{ lib, ... }:
{
  options.rl.logs = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    endpoint = lib.mkOption { type = lib.types.str; default = "http://localhost:4317"; };
    level = lib.mkOption { type = lib.types.enum [ "debug" "info" "warn" "error" ]; default = "info"; };
  };
}
