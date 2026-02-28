"""ROSGraph — ROS2 node topology artifact (4 params)"""
from pydantic import BaseModel, Field
class ROSGraph(BaseModel):
    nodes: int = Field(default=5, ge=1, le=100)
    topics: int = Field(default=10, ge=1, le=500)
    services: int = Field(default=3, ge=0, le=100)
    rate_hz: float = Field(default=30.0, gt=0.0, le=1000.0)
