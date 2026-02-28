"""PythonURDF — Robot description artifact (6 params)"""
from pydantic import BaseModel, Field
class URDF(BaseModel):
    links: int = Field(default=5, ge=1, le=100)
    joints: int = Field(default=4, ge=0, le=99)
    sensors: int = Field(default=2, ge=0, le=50)
    actuators: int = Field(default=4, ge=0, le=50)
    total_mass_kg: float = Field(default=5.0, gt=0.0, le=500.0)
    name: str = Field(default="robot", description="Robot name identifier")
