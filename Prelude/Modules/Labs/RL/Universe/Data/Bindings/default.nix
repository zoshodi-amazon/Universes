# Data Bindings - map abstract data options to provider-specific ENV vars
{ config, lib, ... }:
let
  cfg = config.rl.data;
  providerEnvVars = {
    csv = { RL_DATA_FILE = "${cfg.dataDir}/sample.csv"; };
    yahoo = {};
    alpaca = {};
    ccxt = {};
  };
in
{
  config.rl._internal.dataEnvVars = providerEnvVars.${cfg.provider} or {};
}
