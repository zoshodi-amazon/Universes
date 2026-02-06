# Obs Options - observability looking glass (runtime logs + persistent db)
{ lib, ... }:
{
  options.rl.obs = {
    dbPath = lib.mkOption { type = lib.types.str; default = "./rl.db"; };
    logDir = lib.mkOption { type = lib.types.str; default = "./logs"; };
    logLevel = lib.mkOption { type = lib.types.enum [ "debug" "info" "warn" "error" ]; default = "info"; };
  };
}
