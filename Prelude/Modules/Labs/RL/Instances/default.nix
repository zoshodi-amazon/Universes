# RL Instances - export devShell + CLI packages
# Consumes Options → ENV vars, exports nushell wrappers around `rl` CLI
{ config, lib, ... }:
let
  cfg = config.rl;
  envVars = {
    RL_ENV_ID = cfg.env.envId;
    RL_ENV_N_ENVS = toString cfg.env.nEnvs;
    RL_AGENT_ALGORITHM = cfg.agent.algorithm;
    RL_AGENT_POLICY = cfg.agent.policyType;
    RL_AGENT_NET_ARCH = builtins.toJSON cfg.agent.netArch;
    RL_TRAIN_TIMESTEPS = toString cfg.train.totalTimesteps;
    RL_TRAIN_LR = cfg.train.learningRate;
    RL_TRAIN_BATCH_SIZE = toString cfg.train.batchSize;
    RL_TRAIN_GAMMA = cfg.train.gamma;
    RL_EVAL_EPISODES = toString cfg.eval.episodes;
    RL_EVAL_DETERMINISTIC = lib.boolToString cfg.eval.deterministic;
    RL_INFER_DEVICE = cfg.infer.device;
    RL_STORE_BACKEND = cfg.store.backend;
    RL_STORE_MODEL_DIR = cfg.store.modelDir;
    RL_STORE_CHECKPOINT_FREQ = toString cfg.store.checkpointFreq;
    RL_OBS_DB_PATH = cfg.obs.dbPath;
    RL_OBS_LOG_DIR = cfg.obs.logDir;
    RL_OBS_LOG_LEVEL = cfg.obs.logLevel;
  } // cfg._internal.storeEnvVars;

  # Config JSON for nushell scripts (typed off Options)
  configJson = builtins.toJSON {
    env = { inherit (cfg.env) envId nEnvs; };
    agent = { inherit (cfg.agent) algorithm policyType netArch; };
    train = { inherit (cfg.train) totalTimesteps learningRate batchSize; gamma = cfg.train.gamma; };
    eval = { inherit (cfg.eval) episodes deterministic; };
    infer = { inherit (cfg.infer) modelPath device; };
    store = { inherit (cfg.store) backend modelDir checkpointFreq; };
    obs = { inherit (cfg.obs) dbPath logDir logLevel; };
  };
in
{
  config.rl.enable = lib.mkDefault true;

  config.perSystem = { pkgs, ... }: lib.mkIf cfg.enable {
    packages = let
      configFile = pkgs.writeText "rl-config.json" configJson;
      mkNuCmd = name: script: pkgs.writeShellScriptBin name ''
        export ${lib.concatStringsSep "\n        export " (lib.mapAttrsToList (k: v: "${k}=\"${v}\"") envVars)}
        exec ${pkgs.nushell}/bin/nu ${script} ${configFile} "$@"
      '';
      scripts = ../Universe;
    in {
      rl-train = mkNuCmd "rl-train" "${scripts}/Train/Bindings/Scripts/default.nu";
      rl-eval = mkNuCmd "rl-eval" "${scripts}/Eval/Bindings/Scripts/default.nu";
      rl-infer = mkNuCmd "rl-infer" "${scripts}/Infer/Bindings/Scripts/default.nu";
      rl-db = mkNuCmd "rl-db" "${scripts}/Obs/Bindings/Scripts/default.nu";
    };

    devShells.rl = pkgs.mkShell {
      name = "rl";
      packages = with pkgs; [ nushell sqlite ];
      shellHook = lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "export ${k}=\"${v}\"") envVars);
    };
  };
}
