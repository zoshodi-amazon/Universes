# Store Bindings - map abstract options to vendor-specific ENV vars
{ config, lib, ... }:
let
  cfg = config.rl.store;
  # Backend-specific ENV var mappings
  backendEnvVars = {
    mlflow = {
      MLFLOW_TRACKING_URI = cfg.trackingUri;
      MLFLOW_EXPERIMENT_NAME = cfg.experimentName;
    } // lib.optionalAttrs (cfg.runName != null) { MLFLOW_RUN_NAME = cfg.runName; };
    
    wandb = {
      WANDB_BASE_URL = cfg.trackingUri;
      WANDB_PROJECT = cfg.experimentName;
    } // lib.optionalAttrs (cfg.runName != null) { WANDB_RUN_NAME = cfg.runName; };
    
    local = {};
    s3 = { AWS_S3_BUCKET = cfg.trackingUri; };
  };
in
{
  config.rl._internal.storeEnvVars = backendEnvVars.${cfg.backend} or {};
}
