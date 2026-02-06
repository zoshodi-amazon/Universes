# Store Options - abstract persistence capability
{ lib, ... }:
{
  options.rl.store = {
    backend = lib.mkOption { type = lib.types.enum [ "local" "s3" "mlflow" "wandb" ]; default = "local"; };
    modelDir = lib.mkOption { type = lib.types.str; default = "./models"; };
    checkpointFreq = lib.mkOption { type = lib.types.int; default = 10000; };
    trackingUri = lib.mkOption { type = lib.types.str; default = "http://localhost:5000"; };
    experimentName = lib.mkOption { type = lib.types.str; default = "rl-experiment"; };
    runName = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
  };
}
