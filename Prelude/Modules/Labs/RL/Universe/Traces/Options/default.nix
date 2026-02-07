# Traces Options - OTEL distributed tracing (episode/step spans)
{ lib, ... }:
{
  options.rl.traces = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    endpoint = lib.mkOption { type = lib.types.str; default = "http://localhost:4317"; };
    sampleRate = lib.mkOption { type = lib.types.str; default = "1.0"; };
    traceEpisodes = lib.mkOption { type = lib.types.bool; default = true; };
    traceSteps = lib.mkOption { type = lib.types.bool; default = false; };
    traceEvals = lib.mkOption { type = lib.types.bool; default = true; };
  };
}
