from ..Options.index import EvalConfig
from stable_baselines3 import PPO, A2C, DQN, SAC, TD3
import gymnasium as gym

ALGOS = {"ppo": PPO, "a2c": A2C, "dqn": DQN, "sac": SAC, "td3": TD3}

def main():
    cfg = EvalConfig()
    algo = ALGOS.get("ppo")  # TODO: get from train config
    model = algo.load(f"{cfg.model_dir}/ppo")
    render_mode = "human" if cfg.render else None
    env = gym.make(cfg.env_id, render_mode=render_mode)
    
    for _ in range(cfg.episodes):
        obs, _ = env.reset()
        done = False
        while not done:
            action, _ = model.predict(obs, deterministic=True)
            obs, _, terminated, truncated, _ = env.step(action)
            done = terminated or truncated
    env.close()

if __name__ == "__main__":
    main()
