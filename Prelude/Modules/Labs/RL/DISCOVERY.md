# RL Module Discovery: Observability & Storage

**Date**: 2026-02-02  
**Focus**: SQLite + OpenTelemetry pairing for RL pipeline

---

## Current State

### Existing Structure
```
RL/
├── Universe/
│   ├── Env/        # Gymnasium environment
│   ├── Obs/        # Observation space (normalize, clip, stack)
│   ├── Feature/    # Feature engineering
│   ├── Agent/      # Policy/algorithm
│   ├── Train/      # Training loop
│   ├── Eval/       # Evaluation
│   ├── Infer/      # Inference
│   └── Store/      # Persistence (backend: local/s3/mlflow/wandb)
├── Drv/
│   ├── mlflow/     # Custom derivation
│   └── sb3/        # Custom derivation
└── Instances/      # Global wiring
```

### Store Options (Current)
```nix
options.rl.store = {
  backend = enum [ "local" "s3" "mlflow" "wandb" ];
  modelDir = str;
  checkpointFreq = int;
  trackingUri = str;           # Generic
  experimentName = str;        # Generic
  runName = nullOr str;
};
```

### Obs Options (Current)
```nix
options.rl.obs = {
  normalize = bool;
  clipRange = nullOr float;
  stackFrames = nullOr int;
};
```

---

## Discovery: SQLite + OTEL Pairing

### Why This Pairing?

| Aspect | SQLite | OpenTelemetry |
|--------|--------|---------------|
| **Purpose** | Metadata, model registry, experiment tracking | Metrics, logs, traces (runtime telemetry) |
| **Data Type** | Structured, discrete (Information) | Continuous streams (Signal) |
| **Lifecycle** | Persistent state across runs | Real-time observability during runs |
| **Queries** | SQL: "Show all models with accuracy > 0.9" | Metrics: "Current training loss", Traces: "Episode timeline" |

### Categorical Alignment

Per the Universes pattern:

| Component | Category | Why |
|-----------|----------|-----|
| **SQLite** | Information | Discrete, structured, stored representation |
| **OTEL Metrics** | Signal | Continuous transmission (reward/loss streams) |
| **OTEL Traces** | Signal | Episode/step sequences |
| **OTEL Logs** | Signal | Event streams during training |
| **Trained Model** | Information | Static artifact |
| **Training Loop** | Computation | Process over time |

### Complementary Roles

```
┌─────────────────────────────────────────────────────────────┐
│                      RL Pipeline                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Training Loop (Computation)                                │
│  ├─ Emits OTEL Metrics ──────────────▶ Signal/Metrics/     │
│  │  (reward, loss, entropy per step)                       │
│  ├─ Emits OTEL Traces ───────────────▶ Signal/Traces/      │
│  │  (episode spans, step spans)                            │
│  └─ Emits OTEL Logs ─────────────────▶ Signal/Logs/        │
│     (checkpoint saved, eval triggered)                      │
│                                                             │
│  Model Checkpoint (Information)                             │
│  └─ Writes Metadata ─────────────────▶ SQLite              │
│     (model_id, timestamp, metrics, hyperparams, path)       │
│                                                             │
│  Validation Layer                                           │
│  ├─ Queries SQLite ──────────────────▶ "Best model?"       │
│  └─ Checks Metrics ──────────────────▶ "Converged?"        │
│                                                             │
│  Hotswap                                                    │
│  └─ Loads from SQLite ───────────────▶ model_path          │
└─────────────────────────────────────────────────────────────┘
```

---

## Proposed Architecture

### New Universe Features

```
RL/Universe/
├── Metrics/        # OTEL metrics (reward, loss, entropy, fps)
│   ├── Options/
│   └── Bindings/
├── Traces/         # OTEL traces (episodes, steps, eval)
│   ├── Options/
│   └── Bindings/
├── Logs/           # OTEL logs (checkpoints, errors)
│   ├── Options/
│   └── Bindings/
└── Registry/       # SQLite model registry
    ├── Options/
    └── Bindings/
```

### Options Design (Vendor-Agnostic)

#### Metrics/Options/default.nix
```nix
{ lib, ... }:
{
  options.rl.metrics = {
    enable = lib.mkEnableOption "OTEL metrics";
    exportInterval = lib.mkOption { type = lib.types.int; default = 10; };  # seconds
    endpoint = lib.mkOption { type = lib.types.str; default = "http://localhost:4318"; };
    protocol = lib.mkOption { type = lib.types.enum ["grpc" "http"]; default = "http"; };
    
    # What to track
    trackReward = lib.mkOption { type = lib.types.bool; default = true; };
    trackLoss = lib.mkOption { type = lib.types.bool; default = true; };
    trackEntropy = lib.mkOption { type = lib.types.bool; default = true; };
    trackFps = lib.mkOption { type = lib.types.bool; default = true; };
  };
}
```

#### Traces/Options/default.nix
```nix
{ lib, ... }:
{
  options.rl.traces = {
    enable = lib.mkEnableOption "OTEL traces";
    endpoint = lib.mkOption { type = lib.types.str; default = "http://localhost:4318"; };
    sampleRate = lib.mkOption { type = lib.types.float; default = 1.0; };  # 0.0-1.0
    
    # Span granularity
    traceEpisodes = lib.mkOption { type = lib.types.bool; default = true; };
    traceSteps = lib.mkOption { type = lib.types.bool; default = false; };  # High volume
    traceEvals = lib.mkOption { type = lib.types.bool; default = true; };
  };
}
```

#### Logs/Options/default.nix
```nix
{ lib, ... }:
{
  options.rl.logs = {
    enable = lib.mkEnableOption "OTEL logs";
    endpoint = lib.mkOption { type = lib.types.str; default = "http://localhost:4318"; };
    level = lib.mkOption { type = lib.types.enum ["debug" "info" "warn" "error"]; default = "info"; };
  };
}
```

#### Registry/Options/default.nix
```nix
{ lib, ... }:
{
  options.rl.registry = {
    enable = lib.mkEnableOption "SQLite model registry";
    dbPath = lib.mkOption { type = lib.types.str; default = "./rl_registry.db"; };
    
    # Validation thresholds
    minReward = lib.mkOption { type = lib.types.nullOr lib.types.float; default = null; };
    minEpisodes = lib.mkOption { type = lib.types.int; default = 10; };
    
    # Retention
    keepTopN = lib.mkOption { type = lib.types.nullOr lib.types.int; default = 10; };
    maxAge = lib.mkOption { type = lib.types.nullOr lib.types.int; default = null; };  # days
  };
}
```

### Bindings (Vendor-Specific)

#### Metrics/Bindings/default.nix
```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.rl.metrics;
in
{
  config = lib.mkIf cfg.enable {
    perSystem = { system, ... }: {
      devShells.rl = {
        buildInputs = with pkgs.python3Packages; [
          opentelemetry-api
          opentelemetry-sdk
          opentelemetry-exporter-otlp
        ];
        shellHook = ''
          export OTEL_METRICS_EXPORTER="otlp"
          export OTEL_EXPORTER_OTLP_ENDPOINT="${cfg.endpoint}"
          export OTEL_EXPORTER_OTLP_PROTOCOL="${cfg.protocol}"
          export RL_METRICS_INTERVAL="${toString cfg.exportInterval}"
        '';
      };
    };
  };
}
```

#### Registry/Bindings/default.nix
```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.rl.registry;
  
  # Schema initialization script
  initSchema = pkgs.writeText "init_registry.sql" ''
    CREATE TABLE IF NOT EXISTS models (
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
    
    CREATE INDEX IF NOT EXISTS idx_timestamp ON models(timestamp);
    CREATE INDEX IF NOT EXISTS idx_mean_reward ON models(mean_reward);
    CREATE INDEX IF NOT EXISTS idx_validated ON models(validated);
  '';
in
{
  config = lib.mkIf cfg.enable {
    perSystem = { system, ... }: {
      devShells.rl = {
        buildInputs = [ pkgs.sqlite ];
        shellHook = ''
          export RL_REGISTRY_DB="${cfg.dbPath}"
          
          # Initialize schema if DB doesn't exist
          if [ ! -f "${cfg.dbPath}" ]; then
            ${pkgs.sqlite}/bin/sqlite3 "${cfg.dbPath}" < ${initSchema}
          fi
          
          ${lib.optionalString (cfg.minReward != null) ''
            export RL_REGISTRY_MIN_REWARD="${toString cfg.minReward}"
          ''}
          export RL_REGISTRY_MIN_EPISODES="${toString cfg.minEpisodes}"
        '';
      };
    };
  };
}
```

---

## ENV Var Mapping (CLI ≅ ENV ≅ Options)

### Current Store Backend
```
Options              ENV                        CLI
-------              ---                        ---
trackingUri          RL_STORE_TRACKING_URI      --tracking-uri
experimentName       RL_STORE_EXPERIMENT_NAME   --experiment-name
backend="mlflow"     RL_STORE_BACKEND=mlflow    --backend mlflow
```

### New Observability
```
Options                    ENV                           CLI
-------                    ---                           ---
metrics.enable             RL_METRICS_ENABLE=1           --metrics
metrics.endpoint           OTEL_EXPORTER_OTLP_ENDPOINT   --metrics-endpoint
metrics.trackReward        RL_METRICS_TRACK_REWARD=1     --track-reward
traces.enable              RL_TRACES_ENABLE=1            --traces
traces.sampleRate          RL_TRACES_SAMPLE_RATE=1.0     --trace-sample-rate
logs.level                 RL_LOGS_LEVEL=info            --log-level
registry.dbPath            RL_REGISTRY_DB=./reg.db       --registry-db
registry.minReward         RL_REGISTRY_MIN_REWARD=0.9    --min-reward
```

---

## Nixpkgs Availability

### OpenTelemetry (Python)
```
✓ python3Packages.opentelemetry-api
✓ python3Packages.opentelemetry-sdk
✓ python3Packages.opentelemetry-exporter-otlp
✓ python3Packages.opentelemetry-exporter-otlp-proto-http
✓ python3Packages.opentelemetry-exporter-otlp-proto-grpc
✓ python3Packages.opentelemetry-instrumentation
```

### SQLite
```
✓ sqlite (core)
✓ python3Packages.sqlite (bindings, built-in)
```

---

## Implementation Strategy

### Phase 1: Registry (SQLite)
1. Create `Universe/Registry/Options/default.nix`
2. Create `Universe/Registry/Bindings/default.nix` with schema init
3. Wire in `Env/default.nix` (aggregate ENV vars)
4. Update `Instances/default.nix` (enable by default)
5. Add Python helper: `Universe/Registry/Bindings/Scripts/default.nu`
   - `rl-registry-add <model_path> <metrics_json>`
   - `rl-registry-list [--validated] [--top-n]`
   - `rl-registry-validate <model_id>`
   - `rl-registry-load <model_id>`

### Phase 2: Metrics (OTEL)
1. Create `Universe/Metrics/Options/default.nix`
2. Create `Universe/Metrics/Bindings/default.nix`
3. Add Python instrumentation wrapper
4. Integrate with `Train/Bindings/` (emit metrics during training)

### Phase 3: Traces (OTEL)
1. Create `Universe/Traces/Options/default.nix`
2. Create `Universe/Traces/Bindings/default.nix`
3. Add span decorators for episodes/steps/evals

### Phase 4: Logs (OTEL)
1. Create `Universe/Logs/Options/default.nix`
2. Create `Universe/Logs/Bindings/default.nix`
3. Replace print statements with structured logging

### Phase 5: Integration
1. Update `Store/Bindings/` to write to Registry on checkpoint
2. Add validation layer: check Registry before loading model
3. Implement hotswap: `rl-load-best` queries Registry, loads model
4. Add `Eval/Bindings/` integration: write eval results to Registry

---

## Validation Layer Design

### Criteria
```python
# Pseudocode
def validate_model(model_id: int) -> bool:
    row = registry.query("SELECT * FROM models WHERE id = ?", model_id)
    
    checks = [
        row.mean_reward >= cfg.minReward if cfg.minReward else True,
        row.total_timesteps >= cfg.minEpisodes * row.mean_episode_length,
        row.std_reward < row.mean_reward * 0.5,  # Not too noisy
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
5. Validation layer checks criteria
6. If passed: validated=1
7. Inference queries: "SELECT model_path FROM models WHERE validated=1 ORDER BY mean_reward DESC LIMIT 1"
8. Load model from path
```

---

## Questions / Decisions

### 1. OTEL Backend?
- **Option A**: Local collector (otel-collector) → Prometheus + Jaeger
- **Option B**: Direct export to cloud (Honeycomb, Datadog, etc.)
- **Option C**: File export for offline analysis
- **Recommendation**: Start with Option C (simplest), add A/B as backends

### 2. Registry Schema Extensions?
- Add `tags` column (JSON) for custom metadata?
- Add `parent_model_id` for fine-tuning lineage?
- Add `deployment_status` enum (staging, production, archived)?

### 3. Metrics Granularity?
- Per-step metrics = high volume, useful for debugging
- Per-episode metrics = lower volume, sufficient for monitoring
- **Recommendation**: Make configurable via `metrics.granularity = enum ["step" "episode"]`

### 4. Existing Store Backend Integration?
- Keep `Store/` as-is (MLflow/Wandb for experiment tracking)
- Add `Registry/` as orthogonal (local model registry)
- Or: Make Registry a Store backend option?
- **Recommendation**: Keep orthogonal. Store = experiments, Registry = models.

---

## Next Steps

1. **Verify**: Does this align with the Universes pattern?
   - Options = vendor-agnostic ✓
   - Bindings = vendor-specific ✓
   - Categorical placement (Information vs Signal) ✓
   - ENV ≅ CLI ≅ Options ✓

2. **Implement**: Start with Phase 1 (Registry)
   - Minimal, self-contained
   - Immediate value (model tracking)
   - Foundation for validation layer

3. **Iterate**: Add OTEL incrementally
   - Metrics first (most valuable)
   - Traces second (debugging)
   - Logs last (nice-to-have)

4. **Document**: Update `RL/README.md` with new capabilities

---

## References

- [MLflow SQLite Backend](https://mlflow.org/docs/latest/tracking/tutorials/local-database/)
- [OpenTelemetry Python](https://opentelemetry.io/docs/languages/python/)
- [TensorFlow ML Metadata](https://tensorflow.org/tfx/guide/mlmd)
- [SQLite for ML Workflows](https://docs.discoverer.bg/sqlite.html)
