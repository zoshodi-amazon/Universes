from pydantic_settings import BaseSettings

class EvalConfig(BaseSettings):
    env_id: str = "CartPole-v1"
    episodes: int = 10
    model_dir: str = "./models"
    render: bool = True

    class Config:
        env_prefix = "RL_EVAL_"
