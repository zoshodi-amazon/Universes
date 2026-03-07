"""PythonPackList — Mode-filtered loadout artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field


class Mode(str, Enum):
    nomadic = "nomadic"
    urban = "urban"
    base = "base"

class Priority(str, Enum):
    critical = "critical"
    essential = "essential"
    operational = "operational"
    expansion = "expansion"

class PackList(BaseModel):
    mode: Mode = Mode.nomadic
    max_weight_kg: float = Field(default=25.0, gt=0.0)
    max_volume_L: float = Field(default=65.0, gt=0.0)
    min_priority: Priority = Priority.critical
