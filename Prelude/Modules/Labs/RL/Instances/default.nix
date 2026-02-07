# RL Instances - export devShell + CLI packages
# Consumes Options -> ENV vars, exports nushell wrappers around `rl` CLI
{ config, lib, ... }:
let
  cfg = config.rl;
  envVars = {
    # Data
    RL_DATA_PROVIDER = cfg.data.provider;
    RL_DATA_TICKERS = builtins.toJSON cfg.data.tickers;
    RL_DATA_INTERVAL = cfg.data.interval;
    RL_DATA_START_DATE = cfg.data.startDate;
    RL_DATA_END_DATE = cfg.data.endDate;
    RL_DATA_INDICATORS = builtins.toJSON cfg.data.indicators;
    RL_DATA_DIR = cfg.data.dataDir;
    # Env
    RL_ENV_ID = cfg.env.envId;
    RL_ENV_N_ENVS = toString cfg.env.nEnvs;
    # Observation
    RL_OBS_NORMALIZE = cfg.observation.normalize;
    RL_OBS_CLIP_RANGE = cfg.observation.clipRange;
    # Agent
    RL_AGENT_ALGORITHM = cfg.agent.algorithm;
    RL_AGENT_POLICY = cfg.agent.policyType;
    RL_AGENT_NET_ARCH = builtins.toJSON cfg.agent.netArch;
    # Train
    RL_TRAIN_TIMESTEPS = toString cfg.train.totalTimesteps;
    RL_TRAIN_LR = cfg.train.learningRate;
    RL_TRAIN_BATCH_SIZE = toString cfg.train.batchSize;
    RL_TRAIN_GAMMA = cfg.train.gamma;
    # Eval
    RL_EVAL_EPISODES = toString cfg.eval.episodes;
    RL_EVAL_DETERMINISTIC = lib.boolToString cfg.eval.deterministic;
    # Infer
    RL_INFER_DEVICE = cfg.infer.device;
    # Execution
    RL_EXEC_PROVIDER = cfg.execution.provider;
    RL_EXEC_MAX_POSITION = cfg.execution.maxPosition;
    # Store
    RL_STORE_BACKEND = cfg.store.backend;
    RL_STORE_MODEL_DIR = cfg.store.modelDir;
    RL_STORE_CHECKPOINT_FREQ = toString cfg.store.checkpointFreq;
    # Registry
    RL_REGISTRY_ENABLE = lib.boolToString cfg.registry.enable;
    RL_REGISTRY_DB_PATH = cfg.registry.dbPath;
    RL_REGISTRY_MIN_REWARD = cfg.registry.minReward;
    RL_REGISTRY_MIN_EPISODES = toString cfg.registry.minEpisodes;
    RL_REGISTRY_KEEP_TOP_N = toString cfg.registry.keepTopN;
    # Telemetry
    RL_TELEMETRY_DB_PATH = cfg.telemetry.dbPath;
    RL_TELEMETRY_LOG_DIR = cfg.telemetry.logDir;
    RL_TELEMETRY_LOG_LEVEL = cfg.telemetry.logLevel;
    # OTEL
    RL_METRICS_ENABLE = lib.boolToString cfg.metrics.enable;
    RL_TRACES_ENABLE = lib.boolToString cfg.traces.enable;
    RL_LOGS_ENABLE = lib.boolToString cfg.logs.enable;
    RL_LOGS_LEVEL = cfg.logs.level;
  } // cfg._internal.storeEnvVars
    // cfg._internal.dataEnvVars
    // cfg._internal.executionEnvVars
    // (lib.optionalAttrs cfg.metrics.enable {
      OTEL_METRICS_EXPORTER = cfg.metrics.protocol;
      OTEL_EXPORTER_OTLP_METRICS_ENDPOINT = cfg.metrics.endpoint;
      RL_METRICS_EXPORT_INTERVAL = toString cfg.metrics.exportInterval;
      RL_METRICS_TRACK_REWARD = lib.boolToString cfg.metrics.trackReward;
      RL_METRICS_TRACK_LOSS = lib.boolToString cfg.metrics.trackLoss;
      RL_METRICS_TRACK_ENTROPY = lib.boolToString cfg.metrics.trackEntropy;
      RL_METRICS_TRACK_FPS = lib.boolToString cfg.metrics.trackFps;
    })
    // (lib.optionalAttrs cfg.traces.enable {
      OTEL_TRACES_EXPORTER = "otlp";
      OTEL_EXPORTER_OTLP_TRACES_ENDPOINT = cfg.traces.endpoint;
      RL_TRACES_SAMPLE_RATE = cfg.traces.sampleRate;
      RL_TRACES_EPISODES = lib.boolToString cfg.traces.traceEpisodes;
      RL_TRACES_STEPS = lib.boolToString cfg.traces.traceSteps;
      RL_TRACES_EVALS = lib.boolToString cfg.traces.traceEvals;
    })
    // (lib.optionalAttrs cfg.logs.enable {
      OTEL_LOGS_EXPORTER = "otlp";
      OTEL_EXPORTER_OTLP_LOGS_ENDPOINT = cfg.logs.endpoint;
    })
    // (lib.optionalAttrs (cfg.observation.stackFrames != null) {
      RL_OBS_STACK_FRAMES = toString cfg.observation.stackFrames;
    })
    // (lib.optionalAttrs (cfg.execution.provider != "backtest") {
      RL_EXEC_API_KEY = cfg.execution.secrets.apiKey;
      RL_EXEC_API_SECRET = cfg.execution.secrets.apiSecret;
      RL_EXEC_API_BASE_URL = cfg.execution.secrets.apiBaseUrl;
    });

  configJson = builtins.toJSON {
    data = { inherit (cfg.data) provider tickers interval startDate endDate indicators dataDir; };
    env = { inherit (cfg.env) envId nEnvs; };
    agent = { inherit (cfg.agent) algorithm policyType netArch; };
    train = { inherit (cfg.train) totalTimesteps learningRate batchSize; gamma = cfg.train.gamma; };
    eval = { inherit (cfg.eval) episodes deterministic; };
    infer = { inherit (cfg.infer) modelPath device; };
    execution = { inherit (cfg.execution) provider maxPosition; };
    store = { inherit (cfg.store) backend modelDir checkpointFreq; };
    observation = { inherit (cfg.observation) normalize clipRange stackFrames; };
    telemetry = { inherit (cfg.telemetry) dbPath logDir logLevel; };
    registry = { inherit (cfg.registry) enable dbPath minReward minEpisodes keepTopN; };
    metrics = { inherit (cfg.metrics) enable endpoint protocol exportInterval; };
    traces = { inherit (cfg.traces) enable endpoint sampleRate; };
    logs = { inherit (cfg.logs) enable endpoint level; };
  };
in
{
  config.rl.enable = lib.mkDefault true;

  config.perSystem = { pkgs, self', ... }: lib.mkIf cfg.enable {
    packages = let
      configFile = pkgs.writeText "rl-config.json" configJson;
      mkNuCmd = name: script: pkgs.writeShellScriptBin name ''
        export ${lib.concatStringsSep "\n        export " (lib.mapAttrsToList (k: v: "${k}=\"${v}\"") envVars)}
        exec ${pkgs.nushell}/bin/nu ${script} ${configFile} "$@"
      '';
      scripts = ../Universe;
    in {
      rl-data = mkNuCmd "rl-data" "${scripts}/Data/Bindings/Scripts/default.nu";
      rl-train = mkNuCmd "rl-train" "${scripts}/Train/Bindings/Scripts/default.nu";
      rl-eval = mkNuCmd "rl-eval" "${scripts}/Eval/Bindings/Scripts/default.nu";
      rl-infer = mkNuCmd "rl-infer" "${scripts}/Infer/Bindings/Scripts/default.nu";
      rl-db = mkNuCmd "rl-db" "${scripts}/Telemetry/Bindings/Scripts/default.nu";
      rl-registry = mkNuCmd "rl-registry" "${scripts}/Registry/Bindings/Scripts/default.nu";
      rl-logs = mkNuCmd "rl-logs" "${scripts}/Logs/Bindings/Scripts/default.nu";
    };

    devShells.rl = pkgs.mkShell {
      name = "rl";
      packages = with pkgs; [ nushell sqlite ] ++ (with self'.packages; [
        rl rl-data rl-train rl-eval rl-infer rl-db rl-registry rl-logs
      ]);
      shellHook = lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "export ${k}=\"${v}\"") envVars);
    };
  };
}
