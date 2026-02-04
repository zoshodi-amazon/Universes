# RL Module

Declarative Reinforcement Learning pipeline with built-in observability.

## Capability Space

The RL pipeline decomposes into these orthogonal capabilities:

| Feature | Purpose | Signature | Category |
|---------|---------|-----------|----------|
| Env | Environment definition (Gym/Gymnasium) | `EnvSpec → Env` | Computation |
| Obs | Observation/state space & preprocessing | `RawObs → ProcessedObs` | Computation |
| Feature | Feature engineering & embeddings | `Obs → Features` | Computation |
| Agent | Policy/algorithm selection | `(Obs, Action) → Policy` | Computation |
| Train | Training loop & hyperparameters | `(Env, Agent) → Model` | Computation |
| Eval | Evaluation & validation | `(Model, Env) → Metrics` | Computation |
| Infer | Inference/deployment | `(Model, Obs) → Action` | Computation |
| Store | Experiment tracking | `Experiment → Artifacts` | Information |
| Registry | Model metadata & validation | `Model → Metadata` | Information |
| Metrics | Runtime telemetry (reward, loss) | `Step → Metrics` | Signal |
| Traces | Episode/step spans | `Episode → Trace` | Signal |
| Logs | Structured events | `Event → Log` | Signal |

## Pipeline Flow

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│   Env   │───▶│   Obs   │───▶│ Feature │───▶│  Agent  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
                                                  │
                                                  ▼
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  Infer  │◀───│Registry │◀───│  Eval   │◀───│  Train  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
                   │              │              │
                   │              │              │
              ┌────┴────┐    ┌───┴───┐    ┌────┴────┐
              │  Store  │    │Metrics│    │ Traces  │
              │(MLflow) │    │(OTEL) │    │ (OTEL)  │
              └─────────┘    └───────┘    └─────────┘
```

## Observability Stack

| Component | Purpose | Backend | Data Type |
|-----------|---------|---------|-----------|
| **Registry** | Model metadata, validation, hotswap | SQLite | Information (discrete) |
| **Store** | Experiment tracking, artifacts | MLflow/Wandb/Local | Information (discrete) |
| **Metrics** | Reward, loss, entropy streams | OTEL → Prometheus | Signal (continuous) |
| **Traces** | Episode/step spans | OTEL → Jaeger | Signal (continuous) |
| **Logs** | Checkpoint events, errors | OTEL → Loki | Signal (continuous) |

### SQLite + OTEL Pairing

```
Training Loop (Computation)
├─ Emits OTEL Metrics ────────▶ Signal/Metrics/ (reward, loss per step)
├─ Emits OTEL Traces ─────────▶ Signal/Traces/ (episode spans)
├─ Emits OTEL Logs ───────────▶ Signal/Logs/ (checkpoint saved)
└─ Writes Model Metadata ─────▶ SQLite Registry (model_id, metrics, path)

Validation Layer
├─ Queries SQLite ────────────▶ "Best validated model?"
└─ Checks Metrics ────────────▶ "Training converged?"

Hotswap
└─ Loads from SQLite ─────────▶ model_path (validated models only)
```

## Options (Type Space)

### Env
- `envId`: Gymnasium environment ID or custom
- `nEnvs`: Number of parallel environments
- `seed`: Random seed

### Obs
- `normalize`: Normalization strategy
- `clipRange`: Clipping bounds
- `stackFrames`: Frame stacking (null or int)

### Feature
- `encoder`: CNN, MLP, Transformer, custom
- `embedDim`: Embedding dimension

### Agent
- `algorithm`: PPO, A2C, DQN, SAC, TD3
- `policyType`: MlpPolicy, CnnPolicy, MultiInputPolicy
- `netArch`: Network architecture

### Train
- `totalTimesteps`: Total training steps
- `learningRate`: Learning rate (string for scientific notation)
- `batchSize`: Batch size
- `gamma`: Discount factor

### Eval
- `episodes`: Number of evaluation episodes
- `deterministic`: Use deterministic actions

### Infer
- `modelPath`: Path to trained model
- `device`: cpu, cuda, mps

### Store
- `backend`: local, s3, mlflow, wandb
- `trackingUri`: Generic tracking endpoint
- `experimentName`: Generic experiment name
- `modelDir`: Model save directory
- `checkpointFreq`: Checkpoint frequency

### Registry (SQLite)
- `enable`: Enable model registry
- `dbPath`: SQLite database path
- `minReward`: Minimum reward threshold for validation
- `minEpisodes`: Minimum episodes for validation
- `keepTopN`: Retain top N models
- `maxAge`: Maximum model age in days

### Metrics (OTEL)
- `enable`: Enable metrics export
- `endpoint`: OTEL collector endpoint
- `protocol`: grpc or http
- `exportInterval`: Export interval in seconds
- `trackReward`: Track reward metric
- `trackLoss`: Track loss metric
- `trackEntropy`: Track entropy metric
- `trackFps`: Track FPS metric

### Traces (OTEL)
- `enable`: Enable trace export
- `endpoint`: OTEL collector endpoint
- `sampleRate`: Trace sampling rate (0.0-1.0)
- `traceEpisodes`: Trace episode spans
- `traceSteps`: Trace step spans (high volume)
- `traceEvals`: Trace evaluation spans

### Logs (OTEL)
- `enable`: Enable log export
- `endpoint`: OTEL collector endpoint
- `level`: debug, info, warn, error

## Bindings (Implementation Space)

Each feature maps to stable-baselines3 / gymnasium / OTEL APIs:

| Feature | Primary Binding | ENV Prefix |
|---------|-----------------|------------|
| Env | `gymnasium.make()` | `RL_ENV_` |
| Obs | `gymnasium.spaces` | `RL_OBS_` |
| Feature | `sb3.common.torch_layers` | `RL_FEAT_` |
| Agent | `sb3.{PPO,A2C,DQN,...}` | `RL_AGENT_` |
| Train | `model.learn()` | `RL_TRAIN_` |
| Eval | `sb3.common.evaluation` | `RL_EVAL_` |
| Infer | `model.predict()` | `RL_INFER_` |
| Store | `model.save/load()` | `RL_STORE_` |
| Registry | `sqlite3` | `RL_REGISTRY_` |
| Metrics | `opentelemetry-api` | `OTEL_METRICS_` |
| Traces | `opentelemetry-sdk` | `OTEL_TRACES_` |
| Logs | `opentelemetry-instrumentation` | `OTEL_LOGS_` |

### ENV ≅ CLI ≅ Options Isomorphism

```
Options                    ENV                           CLI
-------                    ---                           ---
trackingUri                RL_STORE_TRACKING_URI         --tracking-uri
experimentName             RL_STORE_EXPERIMENT_NAME      --experiment-name
backend="mlflow"           RL_STORE_BACKEND=mlflow       --backend mlflow
registry.dbPath            RL_REGISTRY_DB=./reg.db       --registry-db
registry.minReward         RL_REGISTRY_MIN_REWARD=0.9    --min-reward
metrics.enable             RL_METRICS_ENABLE=1           --metrics
metrics.endpoint           OTEL_EXPORTER_OTLP_ENDPOINT   --metrics-endpoint
traces.sampleRate          RL_TRACES_SAMPLE_RATE=1.0     --trace-sample-rate
logs.level                 RL_LOGS_LEVEL=info            --log-level
```

### SQLite Registry Schema

```sql
CREATE TABLE models (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  model_path TEXT NOT NULL,
  algorithm TEXT NOT NULL,
  env_id TEXT NOT NULL,
  timestamp INTEGER NOT NULL,
  total_timesteps INTEGER,
  mean_reward REAL,
  std_reward REAL,
  mean_episode_length REAL,
  hyperparams TEXT,  -- JSON
  git_commit TEXT,
  validated BOOLEAN DEFAULT 0
);

CREATE INDEX idx_timestamp ON models(timestamp);
CREATE INDEX idx_mean_reward ON models(mean_reward);
CREATE INDEX idx_validated ON models(validated);
```

### Validation Layer

```python
def validate_model(model_id: int) -> bool:
    row = registry.query("SELECT * FROM models WHERE id = ?", model_id)
    
    checks = [
        row.mean_reward >= cfg.minReward if cfg.minReward else True,
        row.total_timesteps >= cfg.minEpisodes * row.mean_episode_length,
        row.std_reward < row.mean_reward * 0.5,  # Stability check
    ]
    
    if all(checks):
        registry.execute("UPDATE models SET validated = 1 WHERE id = ?", model_id)
        return True
    return False
```

### Hotswap Flow

```
1. Training loop saves checkpoint
2. Checkpoint callback writes to Registry (validated=0)
3. Eval callback runs evaluation
4. Eval writes metrics to Registry row
5. Validation layer checks criteria → validated=1 if passed
6. Inference queries: SELECT model_path FROM models WHERE validated=1 ORDER BY mean_reward DESC LIMIT 1
7. Load model from path
```

## Usage

```nix
{
  rl = {
    enable = true;
    
    # Core pipeline
    env.envId = "CartPole-v1";  # or "forex-v0", "stocks-v0" for gym-anytrading
    env.nEnvs = 8;
    agent.algorithm = "ppo";
    agent.netArch = [ 64 64 ];
    train.totalTimesteps = 100000;
    train.learningRate = "3e-4";
    eval.episodes = 10;
    
    # Experiment tracking (optional)
    store.backend = "mlflow";
    store.trackingUri = "http://localhost:5000";
    store.experimentName = "cartpole-ppo";
    
    # Model registry (default: enabled)
    registry.enable = true;
    registry.dbPath = "./rl_registry.db";
    registry.minReward = 195.0;  # CartPole-v1 solved threshold
    registry.keepTopN = 10;
    
    # Observability (optional)
    metrics.enable = true;
    metrics.trackReward = true;
    metrics.trackLoss = true;
    traces.enable = true;
    traces.traceEpisodes = true;
    logs.enable = true;
    logs.level = "info";
  };
}
```

```bash
# No need for nix develop - interact via CLI directly
rl-train                              # Training with automatic registry tracking
rl-registry-list --validated --top-n 5  # Query registry
rl-registry-validate <model_id>       # Validate model
rl-infer --load-best                  # Load best model for inference
rl-eval --model-id <id>               # Evaluation
```

## Module Wrapping Philosophy

Once wrapped as a Nix module, you interact via CLI/ENV vars only. No shells, no per-system package management. The module handles:

1. **Options** → Abstract capability (vendor-agnostic)
2. **Bindings** → ENV vars + CLI commands (vendor-specific)
3. **Instances** → Nix packages/commands exported globally

This prevents per-system breakage and maintains the Options ⊣ Bindings adjunction.

## Environment Discovery

```bash
# Introspect available options for any module
introspect-options Modules/Computation/Services/RL

# Output:
# 📋 Features in Modules/Computation/Services/RL/Universe/
# 
# 🔹 Env
#     • envId
#     • nEnvs
#     • seed
# 🔹 Agent
#     • algorithm
#     • policyType
#     • netArch
# ...
```

## Supported Environments

| Environment | envId | Source | Notes |
|-------------|-------|--------|-------|
| CartPole | `CartPole-v1` | gymnasium | Classic control |
| LunarLander | `LunarLander-v2` | gymnasium | Box2D |
| MuJoCo Ant | `Ant-v4` | gymnasium | Robotics |
| FOREX Trading | `forex-v0` | gym-anytrading | Financial (custom Drv) |
| Stock Trading | `stocks-v0` | gym-anytrading | Financial (custom Drv) |

Any Gymnasium-compatible environment works via `envId` option.

## Nixpkgs Dependencies

All dependencies are wrapped as Nix derivations in `Drv/`:

| Package | Purpose | Status |
|---------|---------|--------|
| `stable-baselines3` | RL algorithms | Custom Drv |
| `mlflow` | Experiment tracking | Custom Drv |
| `gym-anytrading` | Trading environments | Custom Drv |
| `sqlite` | Model registry | nixpkgs ✓ |
| `opentelemetry-*` | Observability | nixpkgs ✓ |

## Targets

| Target | Purpose |
|--------|---------|
| `perSystem.devShells.rl` | Development environment with sb3 + gymnasium + sqlite + otel |
| `perSystem.packages.rl-train` | Training script |
| `perSystem.packages.rl-eval` | Evaluation script |
| `perSystem.packages.rl-infer` | Inference script |
| `perSystem.packages.rl-registry-list` | List models in registry |
| `perSystem.packages.rl-registry-validate` | Validate model by ID |

## Implementation Phases

### Phase 1: Registry (SQLite) ✓
- [x] `Universe/Registry/Options/default.nix`
- [x] `Universe/Registry/Bindings/default.nix` with schema init
- [ ] `Universe/Registry/Bindings/Scripts/default.nu` (CLI helpers)
- [ ] Wire in `Env/default.nix`
- [ ] Update `Instances/default.nix`

### Phase 2: Metrics (OTEL)
- [ ] `Universe/Metrics/Options/default.nix`
- [ ] `Universe/Metrics/Bindings/default.nix`
- [ ] Integrate with `Train/Bindings/`

### Phase 3: Traces (OTEL)
- [ ] `Universe/Traces/Options/default.nix`
- [ ] `Universe/Traces/Bindings/default.nix`
- [ ] Add span decorators

### Phase 4: Logs (OTEL)
- [ ] `Universe/Logs/Options/default.nix`
- [ ] `Universe/Logs/Bindings/default.nix`
- [ ] Structured logging

### Phase 5: Integration
- [ ] `Store/Bindings/` writes to Registry on checkpoint
- [ ] Validation layer checks before model load
- [ ] Hotswap: `rl-load-best` queries Registry
- [ ] `Eval/Bindings/` writes results to Registry

## Notes

| Issue | Solution |
|-------|----------|
| Float literals in Nix | Use `lib.types.str` for scientific notation like "3e-4" |
| OTEL backend choice | Start with file export, add collector later |
| Registry vs Store | Registry = models (local), Store = experiments (MLflow/Wandb) |
| Metrics granularity | Per-episode default, per-step optional (high volume) |
| Model hotswap | Query Registry for best validated model, load path |
