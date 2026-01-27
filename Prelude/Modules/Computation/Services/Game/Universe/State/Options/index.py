from pydantic_settings import BaseSettings

class StateConfig(BaseSettings):
    save_dir: str = "./saves"
    autosave: bool = True
    autosave_interval: int = 300

    class Config:
        env_prefix = "GAME_STATE_"
