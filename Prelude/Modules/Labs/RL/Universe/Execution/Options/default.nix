# Execution Options - abstract trade execution contract
{ lib, ... }:
{
  options.rl.execution = {
    provider = lib.mkOption { type = lib.types.enum [ "backtest" "paper" "live" ]; default = "backtest"; };
    maxPosition = lib.mkOption { type = lib.types.str; default = "100"; };
  };
}
