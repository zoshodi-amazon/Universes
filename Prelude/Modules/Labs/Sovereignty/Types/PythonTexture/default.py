"""PythonTexture — Surface/material map artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class TextureFormat(str, Enum):
    png = "png"; exr = "exr"
class Texture(BaseModel):
    resolution_px: int = Field(default=1024, ge=64, le=8192)
    channels: int = Field(default=4, ge=1, le=4)
    format: TextureFormat = TextureFormat.png
