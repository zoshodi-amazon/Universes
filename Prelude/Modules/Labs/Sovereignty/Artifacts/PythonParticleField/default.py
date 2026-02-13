"""PythonParticleField — N-body/particle simulation artifact (4 params)"""
from pydantic import BaseModel, Field

class ParticleField(BaseModel):
    count: int = Field(default=1000, ge=1, le=1_000_000)
    timestep_s: float = Field(default=0.001, gt=0.0, le=1.0)
    bounds_m: float = Field(default=10.0, gt=0.0, le=10000.0)
    gravity: float = Field(default=9.81, ge=0.0, le=100.0)
