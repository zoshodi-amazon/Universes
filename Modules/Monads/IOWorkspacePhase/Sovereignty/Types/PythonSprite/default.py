"""PythonSprite — 2D pixel art artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class SpriteFormat(str, Enum):
    png = "png"; aseprite = "aseprite"
class Sprite(BaseModel):
    width_px: int = Field(default=32, ge=1, le=4096)
    height_px: int = Field(default=32, ge=1, le=4096)
    frame_count: int = Field(default=1, ge=1, le=256)
    format: SpriteFormat = SpriteFormat.png
