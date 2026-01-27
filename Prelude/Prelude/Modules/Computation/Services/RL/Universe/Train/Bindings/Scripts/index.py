from ..Options.index import TrainConfig
from stable_baselines3 import PPO, A2C, DQN, SAC, TD3
from stable_baselines3.common.env_util import make_vec_env

ALGOS = {"ppo": PPO, "a2c": A2C, "dqn": DQN, "sac": SAC, "td3": TD3}

def main():
    cfg = TrainConfig()
    env = make_vec_env(cfg.env_id, n_envs=cfg.n_envs)
    algo = ALGOS[cfg.algorithm]
    model = algo("MlpPolicy", env, verbose=1, tensorboard_log=cfg.log_dir)
    model.learn(total_timesteps=cfg.total_timesteps)
    model.save(f"{cfg.model_dir}/{cfg.algorithm}")

if __name__ == "__main__":
    main()
