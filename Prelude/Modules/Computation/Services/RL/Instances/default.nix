# RL Instances - wire options to ENV vars
{ config, lib, ... }:
let
  cfg = config.rl;
  coreEnvVars = {
    RL_ENV_ID = cfg.env.envId;
    RL_ENV_N_ENVS = toString cfg.env.nEnvs;
    RL_OBS_NORMALIZE = lib.boolToString cfg.obs.normalize;
    RL_FEATURE_ENCODER = cfg.feature.encoder;
    RL_FEATURE_EMBED_DIM = toString cfg.feature.embedDim;
    RL_AGENT_ALGORITHM = cfg.agent.algorithm;
    RL_AGENT_POLICY = cfg.agent.policyType;
    RL_AGENT_NET_ARCH = builtins.toJSON cfg.agent.netArch;
    RL_TRAIN_TIMESTEPS = toString cfg.train.totalTimesteps;
    RL_TRAIN_LR = cfg.train.learningRate;
    RL_TRAIN_BATCH_SIZE = toString cfg.train.batchSize;
    RL_TRAIN_GAMMA = cfg.train.gamma;
    RL_TRAIN_LOG_DIR = cfg.train.logDir;
    RL_EVAL_EPISODES = toString cfg.eval.episodes;
    RL_EVAL_DETERMINISTIC = lib.boolToString cfg.eval.deterministic;
    RL_INFER_MODEL_PATH = cfg.infer.modelPath;
    RL_INFER_DEVICE = cfg.infer.device;
    RL_STORE_BACKEND = cfg.store.backend;
    RL_STORE_MODEL_DIR = cfg.store.modelDir;
    RL_STORE_CHECKPOINT_FREQ = toString cfg.store.checkpointFreq;
  };
  allEnvVars = coreEnvVars // cfg._internal.storeEnvVars;
in
{
  config.rl.enable = lib.mkDefault true;
  config.rl.env.vars = allEnvVars;
}
