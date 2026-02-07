# Data Options - abstract market data contract
{ lib, ... }:
{
  options.rl.data = {
    provider = lib.mkOption { type = lib.types.enum [ "csv" "yahoo" "alpaca" "ccxt" ]; default = "csv"; };
    tickers = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "AAPL" ]; };
    interval = lib.mkOption { type = lib.types.enum [ "1m" "5m" "15m" "1h" "1d" ]; default = "1d"; };
    startDate = lib.mkOption { type = lib.types.str; default = "2020-01-01"; };
    endDate = lib.mkOption { type = lib.types.str; default = "2023-12-31"; };
    indicators = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "macd" "rsi_30" ]; };
    dataDir = lib.mkOption { type = lib.types.str; default = "./.lab/data"; };
  };
}
