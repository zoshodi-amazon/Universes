from pydantic_settings import BaseSettings

class InputConfig(BaseSettings):
    key_repeat_delay: int = 500
    key_repeat_interval: int = 50

    class Config:
        env_prefix = "GAME_INPUT_"
