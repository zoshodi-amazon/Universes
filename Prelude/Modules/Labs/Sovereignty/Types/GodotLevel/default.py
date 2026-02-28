"""GodotLevel — Playable level/map artifact (4 params)"""
from pydantic import BaseModel, Field
class Level(BaseModel):
    width_tiles: int = Field(default=64, ge=1, le=4096)
    height_tiles: int = Field(default=64, ge=1, le=4096)
    entities: int = Field(default=10, ge=0, le=10000)
    triggers: int = Field(default=0, ge=0, le=1000)
