# RL Module

Reinforcement learning with stable-baselines3.

## Structure

```
RL/
├── Universe/
│   ├── Train/
│   │   ├── Options/
│   │   │   ├── index.nix
│   │   │   └── index.py
│   │   └── Bindings/
│   │       └── Scripts/index.py
│   ├── Eval/
│   │   ├── Options/
│   │   │   ├── index.nix
│   │   │   └── index.py
│   │   └── Bindings/
│   │       └── Scripts/index.py
│   └── index.nix
├── Env/index.nix
├── Drv/
│   ├── index.nix
│   └── pyproject.toml
├── Instances/index.nix
└── index.nix
```

## Usage

```nix
{
  rl.train.algorithm = "ppo";
  rl.train.totalTimesteps = 100000;
  rl.eval.episodes = 10;
}
```

```bash
nix develop .#rl
rl-train
rl-eval
```
