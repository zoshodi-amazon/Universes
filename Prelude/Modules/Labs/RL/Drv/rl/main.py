#!/usr/bin/env python3
"""rl - Reinforcement Learning CLI wrapping stable-baselines3.

All configuration via ENV vars (set by Nix module Options -> Env).
Nushell scripts call this CLI — never import Python directly.

Subcommands:
  data preview   - Show dataset summary
  data download  - Fetch from provider to dataDir
  train          - Train with checkpoint callbacks + OTEL
  eval           - Evaluate model, write to registry
  infer          - Run inference
  registry       - Query/validate/prune SQLite model registry
"""
import argparse
import json
import logging
import os
import sqlite3
import sys
import time
from pathlib import Path


def get_env(key, default=None):
    return os.environ.get(key, default)


def get_env_bool(key, default=False):
    return get_env(key, str(default).lower()) in ("true", "1", "yes")


# ---------------------------------------------------------------------------
# SQLite Registry
# ---------------------------------------------------------------------------

def init_db(db_path):
    db = sqlite3.connect(db_path)
    db.row_factory = sqlite3.Row
    db.execute("""CREATE TABLE IF NOT EXISTS runs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        env_id TEXT NOT NULL,
        algorithm TEXT NOT NULL,
        timesteps INTEGER,
        mean_reward REAL,
        std_reward REAL,
        mean_ep_length REAL,
        model_path TEXT,
        hyperparams TEXT,
        validated INTEGER DEFAULT 0,
        timestamp INTEGER DEFAULT (strftime('%s','now'))
    )""")
    db.execute("CREATE INDEX IF NOT EXISTS idx_reward ON runs(mean_reward)")
    db.execute("CREATE INDEX IF NOT EXISTS idx_validated ON runs(validated)")
    db.commit()
    return db


# ---------------------------------------------------------------------------
# OTEL (lazy init)
# ---------------------------------------------------------------------------

_tracer = None
_meter = None


def _init_otel_metrics():
    global _meter
    if _meter or not get_env_bool("RL_METRICS_ENABLE"):
        return _meter
    try:
        from opentelemetry import metrics
        from opentelemetry.sdk.metrics import MeterProvider
        from opentelemetry.sdk.metrics.export import ConsoleMetricExporter, PeriodicExportingMetricReader
        interval = int(get_env("RL_METRICS_EXPORT_INTERVAL", "10")) * 1000
        reader = PeriodicExportingMetricReader(ConsoleMetricExporter(), export_interval_millis=interval)
        metrics.set_meter_provider(MeterProvider(metric_readers=[reader]))
        _meter = metrics.get_meter("rl")
    except ImportError:
        pass
    return _meter


def _init_otel_traces():
    global _tracer
    if _tracer or not get_env_bool("RL_TRACES_ENABLE"):
        return _tracer
    try:
        from opentelemetry import trace
        from opentelemetry.sdk.trace import TracerProvider
        from opentelemetry.sdk.trace.export import ConsoleSpanExporter, BatchSpanProcessor
        provider = TracerProvider()
        provider.add_span_processor(BatchSpanProcessor(ConsoleSpanExporter()))
        trace.set_tracer_provider(provider)
        _tracer = trace.get_tracer("rl")
    except ImportError:
        pass
    return _tracer


def setup_logging():
    level = getattr(logging, get_env("RL_LOGS_LEVEL", get_env("RL_TELEMETRY_LOG_LEVEL", "info")).upper(), logging.INFO)
    log_dir = Path(get_env("RL_TELEMETRY_LOG_DIR", "./logs"))
    log_dir.mkdir(parents=True, exist_ok=True)
    logging.basicConfig(
        level=level,
        format="%(asctime)s %(levelname)s %(name)s %(message)s",
        handlers=[logging.StreamHandler(), logging.FileHandler(log_dir / "rl.log")],
    )
    if get_env_bool("RL_LOGS_ENABLE"):
        try:
            from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler
            from opentelemetry.sdk._logs.export import ConsoleLogExporter, BatchLogRecordProcessor
            lp = LoggerProvider()
            lp.add_log_record_processor(BatchLogRecordProcessor(ConsoleLogExporter()))
            logging.getLogger().addHandler(LoggingHandler(level=logging.NOTSET, logger_provider=lp))
        except ImportError:
            pass


log = logging.getLogger("rl")


# ---------------------------------------------------------------------------
# Data commands
# ---------------------------------------------------------------------------

def cmd_data(args):
    if args.action == "preview":
        import pandas as pd
        data_file = get_env("RL_DATA_FILE", args.file)
        if not data_file or not Path(data_file).exists():
            print(f"No data file found: {data_file}", file=sys.stderr)
            sys.exit(1)
        df = pd.read_csv(data_file)
        print(f"File: {data_file}")
        print(f"Rows: {len(df)}")
        print(f"Columns: {list(df.columns)}")
        print(f"Date range: {df.iloc[0, 0]} to {df.iloc[-1, 0]}")
        print()
        print(df.head(10).to_string(index=False))

    elif args.action == "download":
        provider = args.provider or get_env("RL_DATA_PROVIDER", "csv")
        output = Path(args.output or get_env("RL_DATA_DIR", "./.lab/data"))
        output.mkdir(parents=True, exist_ok=True)

        if provider == "yahoo":
            import yfinance as yf
            tickers = args.tickers.split(",") if args.tickers else ["AAPL"]
            for t in tickers:
                df = yf.download(t, start=args.start, end=args.end, interval=args.interval)
                out_file = output / f"{t}.csv"
                df.to_csv(out_file)
                print(f"Saved: {out_file} ({len(df)} rows)")
        elif provider == "csv":
            print("CSV provider: data already local. Nothing to download.")
        else:
            print(f"Provider '{provider}' download not yet implemented.", file=sys.stderr)
            sys.exit(1)


# ---------------------------------------------------------------------------
# Checkpoint Callback
# ---------------------------------------------------------------------------

class RegistryCheckpointCallback:
    def __init__(self, freq, model_dir, db_path, env_id, algo, hp):
        self.freq = freq
        self.model_dir = Path(model_dir)
        self.model_dir.mkdir(parents=True, exist_ok=True)
        self.db_path = db_path
        self.env_id = env_id
        self.algo = algo
        self.hp = hp
        self.n_calls = 0

    def on_step(self, model, n_steps):
        self.n_calls += 1
        if self.n_calls % self.freq != 0:
            return
        path = str(self.model_dir / f"{self.algo}_{self.env_id}_{n_steps}")
        model.save(path)
        db = init_db(self.db_path)
        db.execute("INSERT INTO runs (env_id, algorithm, timesteps, model_path, hyperparams) VALUES (?,?,?,?,?)",
                   (self.env_id, self.algo, n_steps, path, json.dumps(self.hp)))
        db.commit()
        db.close()
        log.info("checkpoint: %s (step %d)", path, n_steps)


# ---------------------------------------------------------------------------
# Train / Eval / Infer
# ---------------------------------------------------------------------------

def cmd_train(args):
    setup_logging()
    import gymnasium as gym
    from stable_baselines3 import PPO, A2C, DQN, SAC, TD3
    from stable_baselines3.common.vec_env import DummyVecEnv, SubprocVecEnv
    from stable_baselines3.common.callbacks import BaseCallback
    from stable_baselines3.common.utils import set_random_seed

    algos = {"ppo": PPO, "a2c": A2C, "dqn": DQN, "sac": SAC, "td3": TD3}
    algo_cls = algos[args.algo.lower()]
    n_envs = int(get_env("RL_ENV_N_ENVS", "4"))
    seed = get_env("RL_ENV_SEED")
    net_arch = json.loads(get_env("RL_AGENT_NET_ARCH", "[64, 64]"))
    policy = get_env("RL_AGENT_POLICY", "MlpPolicy")
    model_dir = get_env("RL_STORE_MODEL_DIR", "./models")
    ckpt_freq = int(get_env("RL_STORE_CHECKPOINT_FREQ", "10000"))

    if seed:
        set_random_seed(int(seed))

    # Pass data file to env if available (only for trading envs)
    data_file = get_env("RL_DATA_FILE")
    trading_envs = {"stocks-v0", "forex-v0"}
    def make_env():
        if data_file and Path(data_file).exists() and args.env in trading_envs:
            import pandas as pd
            df = pd.read_csv(data_file)
            return gym.make(args.env, df=df, frame_bound=(10, len(df)), window_size=10)
        return gym.make(args.env)

    env = DummyVecEnv([make_env] * n_envs) if n_envs <= 4 else SubprocVecEnv([make_env] * n_envs)
    hp = {"lr": args.lr, "net_arch": net_arch, "policy": policy,
          "batch_size": int(get_env("RL_TRAIN_BATCH_SIZE", "64")),
          "gamma": float(get_env("RL_TRAIN_GAMMA", "0.99"))}

    model = algo_cls(policy, env, learning_rate=float(args.lr), batch_size=hp["batch_size"],
                     gamma=hp["gamma"], policy_kwargs={"net_arch": net_arch}, verbose=1)

    reg_cb = RegistryCheckpointCallback(ckpt_freq, model_dir, args.db, args.env, args.algo, hp)

    class _Cb(BaseCallback):
        def _on_step(self):
            reg_cb.on_step(self.model, self.num_timesteps)
            meter = _init_otel_metrics()
            if meter and get_env_bool("RL_METRICS_TRACK_REWARD"):
                for info in self.locals.get("infos", []):
                    if "episode" in info:
                        meter.create_histogram("rl.episode.reward").record(info["episode"]["r"], {"env": args.env})
            tracer = _init_otel_traces()
            if tracer and get_env_bool("RL_TRACES_EPISODES"):
                for info in self.locals.get("infos", []):
                    if "episode" in info:
                        with tracer.start_as_current_span("episode") as span:
                            span.set_attribute("reward", info["episode"]["r"])
                            span.set_attribute("env", args.env)
            return True

    log.info("train start: env=%s algo=%s steps=%d", args.env, args.algo, args.timesteps)
    model.learn(total_timesteps=args.timesteps, callback=_Cb())

    final_path = str(Path(model_dir) / f"{args.algo}_{args.env}_{args.timesteps}")
    model.save(final_path)
    db = init_db(args.db)
    db.execute("INSERT INTO runs (env_id, algorithm, timesteps, model_path, hyperparams) VALUES (?,?,?,?,?)",
               (args.env, args.algo, args.timesteps, final_path, json.dumps(hp)))
    db.commit()
    db.close()
    log.info("train complete: %s", final_path)
    env.close()


def cmd_eval(args):
    setup_logging()
    from stable_baselines3 import PPO, A2C, DQN, SAC, TD3
    from stable_baselines3.common.evaluation import evaluate_policy
    import gymnasium as gym

    algos = {"ppo": PPO, "a2c": A2C, "dqn": DQN, "sac": SAC, "td3": TD3}
    algo_name = Path(args.model).name.split("_")[0]
    model = algos.get(algo_name, PPO).load(args.model)
    env_id = get_env("RL_ENV_ID", "CartPole-v1")

    data_file = get_env("RL_DATA_FILE")
    trading_envs = {"stocks-v0", "forex-v0"}
    if data_file and Path(data_file).exists() and env_id in trading_envs:
        import pandas as pd
        df = pd.read_csv(data_file)
        env = gym.make(env_id, df=df, frame_bound=(10, len(df)), window_size=10)
    else:
        env = gym.make(env_id)

    mean_reward, std_reward = evaluate_policy(
        model, env, n_eval_episodes=args.episodes,
        deterministic=get_env("RL_EVAL_DETERMINISTIC", "true").lower() == "true")

    print(f"mean_reward={mean_reward:.2f} +/- {std_reward:.2f}")

    min_reward = float(get_env("RL_REGISTRY_MIN_REWARD", "0"))
    db = init_db(args.db)
    db.execute("UPDATE runs SET mean_reward=?, std_reward=?, validated=? WHERE model_path=?",
               (mean_reward, std_reward, 1 if mean_reward >= min_reward else 0, args.model))
    db.commit()
    db.close()
    log.info("eval: model=%s reward=%.2f validated=%s", args.model, mean_reward, mean_reward >= min_reward)
    env.close()


def cmd_infer(args):
    setup_logging()
    from stable_baselines3 import PPO, A2C, DQN, SAC, TD3
    import gymnasium as gym

    algos = {"ppo": PPO, "a2c": A2C, "dqn": DQN, "sac": SAC, "td3": TD3}
    algo_name = Path(args.model).name.split("_")[0]
    model = algos.get(algo_name, PPO).load(args.model, device=args.device)
    env_id = get_env("RL_ENV_ID", "CartPole-v1")

    data_file = get_env("RL_DATA_FILE")
    trading_envs = {"stocks-v0", "forex-v0"}
    if data_file and Path(data_file).exists() and env_id in trading_envs:
        import pandas as pd
        df = pd.read_csv(data_file)
        env = gym.make(env_id, df=df, frame_bound=(10, len(df)), window_size=10)
    else:
        env = gym.make(env_id, render_mode="human" if args.render else None)

    obs, _ = env.reset()
    total_reward = 0
    while True:
        action, _ = model.predict(obs, deterministic=True)
        obs, reward, terminated, truncated, _ = env.step(action)
        total_reward += reward
        if terminated or truncated:
            print(f"Episode reward: {total_reward}")
            log.info("episode reward: %.2f", total_reward)
            obs, _ = env.reset()
            total_reward = 0
            if not args.loop:
                break
    env.close()


# ---------------------------------------------------------------------------
# Registry
# ---------------------------------------------------------------------------

def cmd_registry(args):
    db = init_db(args.db)
    if args.action == "list":
        q = "SELECT id, env_id, algorithm, timesteps, mean_reward, std_reward, validated, model_path FROM runs"
        if args.validated:
            q += " WHERE validated=1"
        q += " ORDER BY mean_reward DESC"
        rows = db.execute(q).fetchall()
        for r in rows:
            v = "Y" if r["validated"] else "N"
            mr = f"{r['mean_reward']:.2f}" if r["mean_reward"] is not None else "---"
            print(f"{r['id']:4d}  {r['env_id']:20s}  {r['algorithm']:5s}  {r['timesteps'] or 0:8d}  reward={mr}  valid={v}  {r['model_path']}")
        if not rows:
            print("(no models)")
    elif args.action == "best":
        row = db.execute("SELECT model_path FROM runs WHERE validated=1 ORDER BY mean_reward DESC LIMIT 1").fetchone()
        if row:
            print(row["model_path"])
        else:
            print("(no validated models)", file=sys.stderr)
            sys.exit(1)
    elif args.action == "validate":
        row = db.execute("SELECT * FROM runs WHERE id=?", (args.id,)).fetchone()
        if not row:
            print(f"Model {args.id} not found", file=sys.stderr)
            sys.exit(1)
        passed = (row["mean_reward"] or 0) >= float(args.min_reward)
        if passed:
            db.execute("UPDATE runs SET validated=1 WHERE id=?", (args.id,))
            db.commit()
            print(f"Model {args.id} validated (reward={row['mean_reward']:.2f})")
        else:
            print(f"Model {args.id} failed (reward={row['mean_reward'] or 0:.2f} < {args.min_reward})")
    elif args.action == "prune":
        keep = int(args.keep_top_n)
        cutoff = int(time.time()) - int(args.max_age) * 86400
        db.execute("DELETE FROM runs WHERE validated=0 AND timestamp < ?", (cutoff,))
        ids = [r["id"] for r in db.execute("SELECT id FROM runs WHERE validated=1 ORDER BY mean_reward DESC").fetchall()]
        if len(ids) > keep:
            to_del = ids[keep:]
            db.execute(f"DELETE FROM runs WHERE id IN ({','.join('?' * len(to_del))})", to_del)
        db.commit()
        print(f"Pruned: kept top {keep}, removed old unvalidated")
    db.close()


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(prog="rl")
    sub = parser.add_subparsers(dest="cmd", required=True)

    # data
    dp = sub.add_parser("data")
    dsub = dp.add_subparsers(dest="action", required=True)
    dprev = dsub.add_parser("preview")
    dprev.add_argument("--file", default=get_env("RL_DATA_FILE", "./.lab/data/sample.csv"))
    ddl = dsub.add_parser("download")
    ddl.add_argument("--provider", default=get_env("RL_DATA_PROVIDER", "csv"))
    ddl.add_argument("--tickers", default=get_env("RL_DATA_TICKERS", "AAPL"))
    ddl.add_argument("--interval", default=get_env("RL_DATA_INTERVAL", "1d"))
    ddl.add_argument("--start", default=get_env("RL_DATA_START_DATE", "2020-01-01"))
    ddl.add_argument("--end", default=get_env("RL_DATA_END_DATE", "2023-12-31"))
    ddl.add_argument("--output", default=get_env("RL_DATA_DIR", "./.lab/data"))

    # train
    p = sub.add_parser("train")
    p.add_argument("--env", default=get_env("RL_ENV_ID", "stocks-v0"))
    p.add_argument("--algo", default=get_env("RL_AGENT_ALGORITHM", "ppo"))
    p.add_argument("--timesteps", type=int, default=int(get_env("RL_TRAIN_TIMESTEPS", "100000")))
    p.add_argument("--lr", default=get_env("RL_TRAIN_LR", "3e-4"))
    p.add_argument("--db", default=get_env("RL_REGISTRY_DB_PATH", "./rl.db"))

    # eval
    p = sub.add_parser("eval")
    p.add_argument("--model", required=True)
    p.add_argument("--episodes", type=int, default=int(get_env("RL_EVAL_EPISODES", "10")))
    p.add_argument("--db", default=get_env("RL_REGISTRY_DB_PATH", "./rl.db"))

    # infer
    p = sub.add_parser("infer")
    p.add_argument("--model", required=True)
    p.add_argument("--device", default=get_env("RL_INFER_DEVICE", "auto"))
    p.add_argument("--render", action="store_true")
    p.add_argument("--loop", action="store_true")

    # registry
    p = sub.add_parser("registry")
    rsub = p.add_subparsers(dest="action", required=True)
    rl_ = rsub.add_parser("list")
    rl_.add_argument("--db", default=get_env("RL_REGISTRY_DB_PATH", "./rl.db"))
    rl_.add_argument("--validated", action="store_true")
    rb = rsub.add_parser("best")
    rb.add_argument("--db", default=get_env("RL_REGISTRY_DB_PATH", "./rl.db"))
    rv = rsub.add_parser("validate")
    rv.add_argument("--db", default=get_env("RL_REGISTRY_DB_PATH", "./rl.db"))
    rv.add_argument("--id", type=int, required=True)
    rv.add_argument("--min-reward", default=get_env("RL_REGISTRY_MIN_REWARD", "0"))
    rv.add_argument("--min-episodes", default=get_env("RL_REGISTRY_MIN_EPISODES", "5"))
    rp = rsub.add_parser("prune")
    rp.add_argument("--db", default=get_env("RL_REGISTRY_DB_PATH", "./rl.db"))
    rp.add_argument("--keep-top-n", default=get_env("RL_REGISTRY_KEEP_TOP_N", "10"))
    rp.add_argument("--max-age", default=get_env("RL_REGISTRY_MAX_AGE", "30"))

    args = parser.parse_args()
    {"data": cmd_data, "train": cmd_train, "eval": cmd_eval, "infer": cmd_infer, "registry": cmd_registry}[args.cmd](args)


if __name__ == "__main__":
    main()
