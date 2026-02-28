"""BlenderScene3D — 3D environment artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class LightingPreset(str, Enum):
    studio = "studio"; outdoor = "outdoor"; night = "night"
class Scene3D(BaseModel):
    lighting: LightingPreset = LightingPreset.studio
    camera_fov: float = Field(default=60.0, ge=10.0, le=180.0)
    objects: int = Field(default=1, ge=1, le=1000)
    format: str = Field(default="glb", description="glb|blend")
