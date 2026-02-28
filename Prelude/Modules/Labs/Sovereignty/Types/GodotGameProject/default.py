"""GodotGameProject — Game project config artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class GameEngine(str, Enum):
    godot = "godot"; bevy = "bevy"
class RenderTarget(str, Enum):
    desktop = "desktop"; mobile = "mobile"; web = "web"
class GameProject(BaseModel):
    engine: GameEngine = GameEngine.godot
    target: RenderTarget = RenderTarget.desktop
    scenes: int = Field(default=1, ge=1, le=1000)
