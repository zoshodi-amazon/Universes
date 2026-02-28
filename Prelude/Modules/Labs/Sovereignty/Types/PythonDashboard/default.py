"""PythonDashboard — TUI panel layout artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class Layout(str, Enum):
    single = "single"; split = "split"; grid = "grid"
class Dashboard(BaseModel):
    layout: Layout = Layout.split
    refresh_rate_s: float = Field(default=1.0, gt=0.0, le=60.0)
    panels: int = Field(default=4, ge=1, le=16)
