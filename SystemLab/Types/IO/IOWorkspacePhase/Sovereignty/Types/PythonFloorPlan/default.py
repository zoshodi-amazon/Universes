"""PythonFloorPlan — Physical space layout artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel, Field

class FloorPlan(BaseModel):
    width_m: float = Field(default=10.0, gt=0.0, le=1000.0)
    depth_m: float = Field(default=10.0, gt=0.0, le=1000.0)
    layers: int = Field(default=1, ge=1, le=10)
