"""BlenderModel3D — 3D character/object artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class ModelFormat(str, Enum):
    glb = "glb"; fbx = "fbx"; blend = "blend"
class Model3D(BaseModel):
    polycount: int = Field(default=5000, ge=100, le=10_000_000)
    materials: int = Field(default=1, ge=1, le=64)
    rigged: bool = False
    format: ModelFormat = ModelFormat.glb
