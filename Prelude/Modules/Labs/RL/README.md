# RL Module

Declarative Reinforcement Learning pipeline with built-in observability.

## Capability Space

### Computation (pipeline stages)

| Feature | Purpose | Signature |
|---------|---------|-----------|
| Env | Environment definition (Gym/Gymnasium) | `EnvSpec -> Env` |
| Observation | State space preprocessing | `RawObs -> ProcessedObs` |
| Feature | Feature engineering (folded into Agent.netArch) | `Obs -> Features` |
| Agent | Policy/algorithm selection | `(Obs, Action) -> Policy` |
| Train | Training loop with checkpoint callbacks | `(Env, Agent) -> Model` |
| Eval | Evaluation and validation | `(Model, Env) -> Metrics` |
| Infer | Inference/deployment | `(Model, Obs) -> Action` |

### Data (market data acquisition)

| Feature | Purpose | Signature |
|---------|---------|-----------|
| Data | Abstract data contract (provider-agnostic) | `DataSpec -> OHLCV` |

Providers: csv (default), yahoo, alpaca, ccxt

### Execution (trade execution)

| Feature | Purpose | Signature |
|---------|---------|-----------|
| Execution | Abstract execution contract (provider-agnostic) | `Order -> Fill` |

Providers: backtest (default), paper, live. Credentials via Secrets binding.

### Information (persistent state)

| Feature | Purpose | Signature |
|---------|---------|-----------|
| Store | Experiment tracking (MLflow/Wandb/local) | `Experiment -> Artifacts` |
| Registry | Model metadata, validation, hotswap (SQLite) | `Model -> Metadata` |

### Signal (runtime telemetry via OTEL)

| Feature | Purpose | Signature |
|---------|---------|-----------|
| Metrics | Reward, loss, entropy, FPS gauges | `Step -> Metric` |
| Traces | Episode/step/eval spans | `Episode -> Trace` |
| Logs | Structured events (checkpoint, error) | `Event -> Log` |

### Observability (looking glass)

| Feature | Purpose | Signature |
|---------|---------|-----------|
| Telemetry | Aggregated view into db + logs | `Config -> Table` |

## Pipeline Flow

```
Data (fetch OHLCV) -> Observation (preprocess) -> Env (gym env with data)
  -> Agent (policy) -> Train (learn) -> Registry (checkpoint)
  -> Eval (backtest) -> Registry (validate) -> Infer (paper/live via Execution)
```

```
+-----------+    +-------------+    +---------+    +---------+
|   Data    |--->| Observation |--->|   Env   |--->|  Agent  |
| (csv/api) |    | (normalize) |    |(gym env)|    | (ppo..) |
+-----------+    +-------------+    +---------+    +---------+
                                                       |
                                                       v
+-----------+    +----------+    +----------+    +---------+
|   Infer   |<---|  Registry|<---|   Eval   |<---|  Train  |
| (execute) |    | (sqlite) |    |(backtest)|    | (learn) |
+-----------+    +----------+    +----------+    +---------+
     |                |              |               |
     v                v              v               v
+-----------+    +---------+    +--------+    +-----------+
| Execution |    |  Store  |    |Metrics |    |  Traces   |
|(paper/live)|   |(mlflow) |    | (OTEL) |    |  (OTEL)   |
+-----------+    +---------+    +--------+    +-----------+
```

## Options (Type Space)

### Data
- `provider`: csv, yahoo, alpaca, ccxt (default: csv)
- `tickers`: list of ticker symbols (default: ["AAPL"])
- `interval`: 1m, 5m, 15m, 1h, 1d (default: 1d)
- `startDate`: start date string (default: "2020-01-01")
- `endDate`: end date string (default: "2023-12-31")
- `indicators`: technical indicators (default: ["macd" "rsi_30"])
- `dataDir`: data storage directory (default: "./.lab/data")

### Execution
- `provider`: backtest, paper, live (default: backtest)
- `maxPosition`: max position size string (default: "100")

### Env
- `envId`: Gymnasium environment ID (default: "stocks-v0")
- `nEnvs`: parallel environments (default: 4)
- `seed`: random seed (default: null)

### Observation
- `normalize`: none, running, fixed (default: none)
- `clipRange`: clipping bounds (default: "10.0")
- `stackFrames`: frame stacking (default: null)

### Agent
- `algorithm`: ppo, a2c, dqn, sac, td3 (default: ppo)
- `policyType`: MlpPolicy, CnnPolicy, MultiInputPolicy (default: MlpPolicy)
- `netArch`: network architecture (default: [64 64])

### Train
- `totalTimesteps`: total training steps (default: 100000)
- `learningRate`: learning rate string (default: "3e-4")
- `batchSize`: batch size (default: 64)
- `gamma`: discount factor string (default: "0.99")

### Eval
- `episodes`: evaluation episodes (default: 10)
- `deterministic`: deterministic actions (default: true)

### Infer
- `modelPath`: path to model (default: "./models/best_model.zip")
- `device`: auto, cpu, cuda, mps (default: auto)

### Store
- `backend`: local, s3, mlflow, wandb (default: local)
- `modelDir`: model save directory (default: "./models")
- `checkpointFreq`: checkpoint frequency (default: 10000)
- `trackingUri`: tracking endpoint (default: "http://localhost:5000")
- `experimentName`: experiment name (default: "rl-experiment")

### Registry
- `enable`: enable model registry (default: true)
- `dbPath`: SQLite path (default: "./rl.db")
- `minReward`: minimum reward for validation (default: "0")
- `minEpisodes`: minimum episodes (default: 5)
- `keepTopN`: retain top N models (default: 10)
- `maxAge`: max model age in days (default: 30)

### Metrics (OTEL)
- `enable`: enable metrics (default: false)
- `endpoint`: collector endpoint (default: "http://localhost:4317")
- `protocol`: grpc, http, console (default: console)
- `exportInterval`: seconds (default: 10)
- `trackReward`, `trackLoss`, `trackEntropy`, `trackFps`: booleans

### Traces (OTEL)
- `enable`: enable traces (default: false)
- `endpoint`: collector endpoint (default: "http://localhost:4317")
- `sampleRate`: 0.0-1.0 (default: "1.0")
- `traceEpisodes`, `traceSteps`, `traceEvals`: booleans

### Logs (OTEL)
- `enable`: enable log export (default: false)
- `endpoint`: collector endpoint (default: "http://localhost:4317")
- `level`: debug, info, warn, error (default: info)

### Telemetry
- `dbPath`: SQLite path (default: "./rl.db")
- `logDir`: log directory (default: "./logs")
- `logLevel`: debug, info, warn, error (default: info)

## Tmux Preset: `just lab`

6 panes, all auto-running:

```
+---------------------------+---------------------------+
| 1. Shell                  | 2. Train (just train)     |
|    interactive commands    |    live training output    |
+---------------------------+---------------------------+
| 3. Registry (just watch)  | 4. Data (just data)       |
|    live model table        |    dataset status/preview  |
+---------------------------+---------------------------+
| 5. Logs (just logs)       | 6. Status (just status)   |
|    tail -f rl.log          |    lab summary + config    |
+---------------------------+---------------------------+
```

Session is named `rl-lab`, resumable via `tmux attach -t rl-lab`.

## End-to-End Walkthrough

```bash
cd Modules/Labs/RL

# 1. Initialize lab workspace with sample CSV data
just init

# 2. Preview dataset
just data

# 3. Train agent (PPO on stocks-v0 with CSV data)
just train

# 4. Evaluate best model
just eval

# 5. Run inference
just infer

# 6. Open full lab IDE (all panes auto-run)
just lab
```

## Lab Justfile

```bash
just --list

# DATA
just data                     # Preview dataset
just download                 # Fetch from provider (yahoo/alpaca)

# TRAIN
just train                    # Train with current config
just train-env stocks-v0      # Train specific env

# EVAL
just eval                     # Evaluate best model
just eval-id 5                # Evaluate model #5

# INFER
just infer                    # Inference with best model

# REGISTRY
just models                   # List all models
just validated                # List validated only
just best                     # Show best model path
just validate 5               # Validate model #5
just prune                    # Clean old models

# TELEMETRY
just logs                     # Tail training logs
just watch                    # Live registry view
just status                   # Lab summary

# CONFIG
just options                  # Show Options type space
just features                 # Show Universe features

# LAB
just lab                      # Open tmux IDE (6 panes, auto-running)
just lab-kill                 # Kill tmux session
just lab-attach               # Reattach to existing session
```

## Bindings (Implementation Space)

| Feature | Primary Binding | ENV Prefix |
|---------|-----------------|------------|
| Data | csv/yfinance/alpaca API | `RL_DATA_` |
| Execution | backtest/paper/live | `RL_EXEC_` |
| Env | `gymnasium.make()` | `RL_ENV_` |
| Observation | `gymnasium.spaces` | `RL_OBS_` |
| Agent | `sb3.{PPO,A2C,DQN,...}` | `RL_AGENT_` |
| Train | `model.learn()` | `RL_TRAIN_` |
| Eval | `sb3.common.evaluation` | `RL_EVAL_` |
| Infer | `model.predict()` | `RL_INFER_` |
| Store | `model.save/load()` | `RL_STORE_` |
| Registry | `sqlite3` | `RL_REGISTRY_` |
| Metrics | `opentelemetry-api` | `OTEL_METRICS_` |
| Traces | `opentelemetry-sdk` | `OTEL_TRACES_` |
| Logs | `opentelemetry-sdk` | `OTEL_LOGS_` |
| Telemetry | `nushell sqlite` | `RL_TELEMETRY_` |

## Targets

| Target | Purpose |
|--------|---------|
| `perSystem.devShells.rl` | Development environment |
| `perSystem.packages.rl-train` | Training script |
| `perSystem.packages.rl-eval` | Evaluation script |
| `perSystem.packages.rl-infer` | Inference script |
| `perSystem.packages.rl-data` | Data preview/download |
| `perSystem.packages.rl-db` | Telemetry query |
| `perSystem.packages.rl-registry` | Registry management |
| `perSystem.packages.rl-logs` | Log tailing |

## Supported Environments

| Environment | envId | Source |
|-------------|-------|--------|
| Stock Trading | `stocks-v0` | gym-anytrading |
| FOREX Trading | `forex-v0` | gym-anytrading |
| CartPole | `CartPole-v1` | gymnasium |
| LunarLander | `LunarLander-v2` | gymnasium |
| MuJoCo Ant | `Ant-v4` | gymnasium |

## Notes

| Issue | Solution |
|-------|----------|
| Float literals in Nix | Use `lib.types.str` for scientific notation like "3e-4" |
| OTEL backend choice | Start with console exporter, add collector later |
| Registry vs Store | Registry = models (local SQLite), Store = experiments (MLflow/Wandb) |
| Data vs Execution | Data = market data feed, Execution = order placement. Can be same or different provider |
| Obs vs Telemetry | Observation = state preprocessing, Telemetry = runtime observability |
| Credentials | Execution/Bindings/Secrets wires sops-nix refs per provider |
| Default test | csv provider + backtest execution = zero external deps |
