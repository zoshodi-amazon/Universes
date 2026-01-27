from pydantic_settings import BaseSettings

class CoreConfig(BaseSettings):
    title: str = "Game"
    fps: int = 60
    width: int = 1920
    height: int = 1080
    fullscreen: bool = False

    class Config:
        env_prefix = "GAME_CORE_"
