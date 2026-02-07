# Execution Bindings - map abstract execution options to provider-specific ENV vars
{ config, lib, ... }:
let
  cfg = config.rl.execution;
  providerEnvVars = {
    backtest = {};
    paper = {};
    live = {};
  };
in
{
  config.rl._internal.executionEnvVars = providerEnvVars.${cfg.provider} or {};
}
