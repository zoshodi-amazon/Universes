"""FEniCSStressField — FEA structural analysis artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field

class FEAMaterial(str, Enum):
    steel = "steel"
    aluminum = "aluminum"
    pla = "pla"
    wood = "wood"
    concrete = "concrete"

class StressField(BaseModel):
    mesh_file: str = Field(default="geometry.stl", description="Input mesh path")
    material: FEAMaterial = FEAMaterial.pla
    load_N: float = Field(default=100.0, gt=0.0, le=1_000_000.0)
    fixed_face: str = Field(default="bottom", description="Fixed boundary face")
