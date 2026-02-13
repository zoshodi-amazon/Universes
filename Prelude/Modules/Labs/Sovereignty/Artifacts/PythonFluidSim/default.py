"""PythonFluidSim — CFD simulation artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field

class FluidType(str, Enum):
    air = "air"
    water = "water"

class FluidSim(BaseModel):
    mesh_file: str = Field(default="geometry.stl", description="Input mesh path")
    fluid: FluidType = FluidType.air
    velocity_ms: float = Field(default=1.0, gt=0.0, le=100.0)
    timestep_s: float = Field(default=0.01, gt=0.0, le=1.0)
