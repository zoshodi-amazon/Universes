from pydantic_settings import BaseSettings

class RenderConfig(BaseSettings):
    vsync: bool = True
    antialiasing: bool = True
    background_color: str = "#000000"

    class Config:
        env_prefix = "GAME_RENDER_"
