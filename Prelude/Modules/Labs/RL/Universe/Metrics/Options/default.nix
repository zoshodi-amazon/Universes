# Metrics Options - OTEL metrics (reward, loss, entropy, fps)
{ lib, ... }:
{
  options.rl.metrics = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    endpoint = lib.mkOption { type = lib.types.str; default = "http://localhost:4317"; };
    protocol = lib.mkOption { type = lib.types.enum [ "grpc" "http" "console" ]; default = "console"; };
    exportInterval = lib.mkOption { type = lib.types.int; default = 10; };
    trackReward = lib.mkOption { type = lib.types.bool; default = true; };
    trackLoss = lib.mkOption { type = lib.types.bool; default = true; };
    trackEntropy = lib.mkOption { type = lib.types.bool; default = false; };
    trackFps = lib.mkOption { type = lib.types.bool; default = false; };
  };
}
