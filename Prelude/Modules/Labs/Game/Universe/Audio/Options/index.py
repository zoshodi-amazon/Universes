from pydantic_settings import BaseSettings

class AudioConfig(BaseSettings):
    master_volume: float = 1.0
    music_volume: float = 0.7
    sfx_volume: float = 1.0
    muted: bool = False

    class Config:
        env_prefix = "GAME_AUDIO_"
