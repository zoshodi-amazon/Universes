"""PythonTilemap — 2D tile grid artifact (3 params)"""
from pydantic import BaseModel, Field
class Tilemap(BaseModel):
    tile_size_px: int = Field(default=16, ge=4, le=128)
    width_tiles: int = Field(default=32, ge=1, le=1024)
    height_tiles: int = Field(default=32, ge=1, le=1024)
