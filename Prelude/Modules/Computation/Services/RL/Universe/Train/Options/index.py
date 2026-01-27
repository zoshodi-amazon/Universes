from pydantic_settings import BaseSettings

class TrainConfig(BaseSettings):
    algorithm: str = "ppo"
    total_timesteps: int = 100000
    n_envs: int = 4
    log_dir: str = "./logs"
    model_dir: str = "./models"

    class Config:
        env_prefix = "RL_TRAIN_"
