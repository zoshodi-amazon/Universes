"""FEniCSThermalField — Heat transfer simulation artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field

class ThermalMaterial(str, Enum):
    steel = "steel"
    aluminum = "aluminum"
    copper = "copper"
    insulation = "insulation"

class ThermalField(BaseModel):
    mesh_file: str = Field(default="geometry.stl", description="Input mesh path")
    material: ThermalMaterial = ThermalMaterial.aluminum
    ambient_c: float = Field(default=25.0, ge=-40.0, le=60.0)
    source_watts: float = Field(default=10.0, ge=0.0, le=10000.0)
