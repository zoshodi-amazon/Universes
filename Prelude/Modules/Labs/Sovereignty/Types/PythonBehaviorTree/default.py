"""PythonBehaviorTree — Decision tree for autonomy artifact (4 params)"""
from pydantic import BaseModel, Field
class BehaviorTree(BaseModel):
    nodes: int = Field(default=10, ge=1, le=1000)
    conditions: int = Field(default=5, ge=0, le=500)
    actions: int = Field(default=5, ge=1, le=500)
    tick_rate_hz: float = Field(default=10.0, gt=0.0, le=1000.0)
