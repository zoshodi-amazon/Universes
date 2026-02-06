#!/usr/bin/env python3
"""rl - Reinforcement Learning CLI wrapping stable-baselines3.

All configuration via ENV vars (set by Nix module Options → Env).
Nushell scripts call this CLI — never import Python directly.
"""
import argparse
import json
import os
import sqlite3
import sys
from pathlib import Path


def get_env(key, default=None):
    return os.environ.get(key, default)


def init_db(db_path):
    db = sqlite3.connect(db_path)
    db.execute("""CREATE TABLE IF NOT EXISTS runs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        env_id TEXT NOT NULL,
        algorithm TEXT NOT NULL,
        timesteps INTEGER,
        mean_reward REAL,
        std_reward REAL,
        model_path TEXT,
        hyperparams TEXT,
        validated INTEGER DEFAULT 0,
        timestamp INTEGER DEFAULT (strftime('%s','now'))
    )""")
    db.execute("CREATE INDEX IF NOT EXISTS idx_reward ON runs(mean_reward)")
    db.execute("CREATE INDEX IF NOT EXISTS idx_validated ON runs(validated)")
    db.commit()
    return db


def cmd_train(args):
    import gymnasium as gym
    from stable_baselines3 import PPO, A2C, DQN, SAC, TD3
    from stable_baselines3.common.vec_env import DummyVecEnv, SubprocVecEnv
    from stable_baselines3.common.utils import set_random_seed

    algos = {"ppo": PPO, "a2c": A2C, "dqn": DQN, "sac": SAC, "td3": TD3}
    algo_cls = algos[args.algo.lower()]

    n_envs = int(get_env("RL_ENV_N_ENVS", "4"))
    seed = get_env("RL_ENV_SEED")
    net_arch = json.loads(get_env("RL_AGENT_NET_ARCH", "[64, 64]"))
    policy = get_env("RL_AGENT_POLICY", "MlpPolicy")

    if seed:
        set_random_seed(int(seed))

    def make_env():
        return gym.make(args.env)

    env = DummyVecEnv([make_env] * n_envs) if n_envs <= 4 else SubprocVecEnv([make_env] * n_envs)

    model = algo_cls(
        policy, env,
        learning_rate=float(args.lr),
        batch_size=int(get_env("RL_TRAIN_BATCH_SIZE", "64")),
        gamma=float(get_env("RL_TRAIN_GAMMA", "0.99")),
        policy_kwargs={"net_arch": net_arch},
        verbose=1,
    )

    log_dir = Path(get_env("RL_OBS_LOG_DIR", "./logs"))
    log_dir.mkdir(parents=True, exist_ok=True)

    model_dir = Path(get_env("RL_STORE_MODEL_DIR", "./models"))
    model_dir.mkdir(parents=True, exist_ok=True)

    model.learn(total_timesteps=args.timesteps)

    model_path = str(model_dir / f"{args.algo}_{args.env}_{args.timesteps}")
    model.save(model_path)

    # Write to registry
    db = init_db(args.db)
    db.execute(
        "INSERT INTO runs (env_id, algorithm, timesteps, model_path, hyperparams) VALUES (?,?,?,?,?)",
        (args.env, args.algo, args.timesteps, model_path,
         json.dumps({"lr": args.lr, "net_arch": net_arch, "policy": policy})),
    )
    db.commit()
    db.close()

    print(f"Saved: {model_path}")
    env.close()


def cmd_eval(args):
    from stable_baselines3 import PPO, A2C, DQN, SAC, TD3
    from stable_baselines3.common.evaluation import evaluate_policy
    import gymnasium as gym

    algos = {"ppo": PPO, "a2c": A2C, "dqn": DQN, "sac": SAC, "td3": TD3}

    # Load model
    algo_name = Path(args.model).name.split("_")[0]
    algo_cls = algos.get(algo_name, PPO)
    model = algo_cls.load(args.model)

    env_id = get_env("RL_ENV_ID", "CartPole-v1")
    env = gym.make(env_id)

    mean_reward, std_reward = evaluate_policy(
        model, env, n_eval_episodes=args.episodes,
        deterministic=get_env("RL_EVAL_DETERMINISTIC", "true").lower() == "true",
    )

    print(f"mean_reward={mean_reward:.2f} +/- {std_reward:.2f}")

    # Update registry
    db = init_db(args.db)
    db.execute(
        "UPDATE runs SET mean_reward=?, std_reward=?, validated=? WHERE model_path=?",
        (mean_reward, std_reward, 1 if mean_reward >= float(get_env("RL_EVAL_MIN_REWARD", "0")) else 0, args.model),
    )
    db.commit()
    db.close()
    env.close()


def cmd_infer(args):
    from stable_baselines3 import PPO, A2C, DQN, SAC, TD3
    import gymnasium as gym

    algos = {"ppo": PPO, "a2c": A2C, "dqn": DQN, "sac": SAC, "td3": TD3}

    algo_name = Path(args.model).name.split("_")[0]
    algo_cls = algos.get(algo_name, PPO)
    model = algo_cls.load(args.model, device=args.device)

    env_id = get_env("RL_ENV_ID", "CartPole-v1")
    env = gym.make(env_id, render_mode="human" if args.render else None)

    obs, _ = env.reset()
    total_reward = 0
    while True:
        action, _ = model.predict(obs, deterministic=True)
        obs, reward, terminated, truncated, _ = env.step(action)
        total_reward += reward
        if terminated or truncated:
            print(f"Episode reward: {total_reward}")
            obs, _ = env.reset()
            total_reward = 0
            if not args.loop:
                break
    env.close()


def main():
    parser = argparse.ArgumentParser(prog="rl", description="RL pipeline CLI")
    sub = parser.add_subparsers(dest="cmd", required=True)

    # train
    p = sub.add_parser("train")
    p.add_argument("--env", default=get_env("RL_ENV_ID", "CartPole-v1"))
    p.add_argument("--algo", default=get_env("RL_AGENT_ALGORITHM", "ppo"))
    p.add_argument("--timesteps", type=int, default=int(get_env("RL_TRAIN_TIMESTEPS", "100000")))
    p.add_argument("--lr", default=get_env("RL_TRAIN_LR", "3e-4"))
    p.add_argument("--db", default=get_env("RL_OBS_DB_PATH", "./rl.db"))

    # eval
    p = sub.add_parser("eval")
    p.add_argument("--model", required=True)
    p.add_argument("--episodes", type=int, default=int(get_env("RL_EVAL_EPISODES", "10")))
    p.add_argument("--db", default=get_env("RL_OBS_DB_PATH", "./rl.db"))

    # infer
    p = sub.add_parser("infer")
    p.add_argument("--model", required=True)
    p.add_argument("--device", default=get_env("RL_INFER_DEVICE", "auto"))
    p.add_argument("--render", action="store_true")
    p.add_argument("--loop", action="store_true")

    args = parser.parse_args()
    {"train": cmd_train, "eval": cmd_eval, "infer": cmd_infer}[args.cmd](args)


if __name__ == "__main__":
    main()
