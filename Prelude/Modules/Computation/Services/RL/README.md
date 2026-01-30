# RL Module

Declarative Reinforcement Learning pipeline.

## Capability Space

The RL pipeline decomposes into these orthogonal capabilities:

| Feature | Purpose | Signature |
|---------|---------|-----------|
| Env | Environment definition (Gym/Gymnasium) | `EnvSpec → Env` |
| Obs | Observation/state space & preprocessing | `RawObs → ProcessedObs` |
| Feature | Feature engineering & embeddings | `Obs → Features` |
| Agent | Policy/algorithm selection | `(Obs, Action) → Policy` |
| Train | Training loop & hyperparameters | `(Env, Agent) → Model` |
| Eval | Evaluation & validation | `(Model, Env) → Metrics` |
| Infer | Inference/deployment | `(Model, Obs) → Action` |
| Store | Model & data persistence | `Path → Artifact` |

## Pipeline Flow

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│   Env   │───▶│   Obs   │───▶│ Feature │───▶│  Agent  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
                                                  │
                                                  ▼
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  Infer  │◀───│  Store  │◀───│  Eval   │◀───│  Train  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘
```

## Options (Type Space)

### Env
- `envId`: Gymnasium environment ID or custom
- `wrappers`: List of env wrappers (frame stack, normalize, etc.)
- `nEnvs`: Number of parallel environments
- `seed`: Random seed

### Obs
- `spaceType`: Box, Discrete, MultiDiscrete, Dict
- `shape`: Observation shape
- `normalize`: Normalization strategy
- `clip`: Clipping bounds

### Feature
- `encoder`: CNN, MLP, Transformer, custom
- `embedDim`: Embedding dimension
- `layers`: Layer configuration

### Agent
- `algorithm`: PPO, A2C, DQN, SAC, TD3, etc.
- `policyType`: MlpPolicy, CnnPolicy, MultiInputPolicy
- `netArch`: Network architecture

### Train
- `totalTimesteps`: Total training steps
- `learningRate`: Learning rate (or schedule)
- `batchSize`: Batch size
- `nEpochs`: Epochs per update
- `gamma`: Discount factor
- `logDir`: Tensorboard log directory

### Eval
- `episodes`: Number of evaluation episodes
- `deterministic`: Use deterministic actions
- `render`: Render environment
- `metrics`: Metrics to compute

### Infer
- `modelPath`: Path to trained model
- `device`: cpu, cuda, mps
- `batchInference`: Enable batched inference

### Store
- `backend`: local, s3, mlflow, wandb
- `modelDir`: Model save directory
- `checkpointFreq`: Checkpoint frequency

## Bindings (Implementation Space)

Each feature maps to stable-baselines3 / gymnasium APIs:

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

## Usage

```nix
{
  rl = {
    enable = true;
    env.envId = "CartPole-v1";
    env.nEnvs = 8;
    agent.algorithm = "ppo";
    agent.netArch = [ 64 64 ];
    train.totalTimesteps = 100000;
    train.learningRate = 3e-4;
    eval.episodes = 10;
    store.backend = "local";
  };
}
```

```bash
nix develop .#rl
rl-train    # Train agent
rl-eval     # Evaluate model
rl-infer    # Run inference
```

## Targets

| Target | Purpose |
|--------|---------|
| `perSystem.devShells.rl` | Development environment |
| `perSystem.packages.rl-train` | Training script |
| `perSystem.packages.rl-eval` | Evaluation script |
| `perSystem.packages.rl-infer` | Inference script |
