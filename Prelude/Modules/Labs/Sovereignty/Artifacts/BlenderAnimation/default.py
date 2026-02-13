"""BlenderAnimation — Motion/skeletal animation artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class AnimFormat(str, Enum):
    glb = "glb"; fbx = "fbx"; blend = "blend"
class Animation(BaseModel):
    frames: int = Field(default=60, ge=1, le=100000)
    fps: int = Field(default=24, ge=1, le=120)
    bones: int = Field(default=0, ge=0, le=500)
    format: AnimFormat = AnimFormat.glb
