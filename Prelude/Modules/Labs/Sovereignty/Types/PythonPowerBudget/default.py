"""PythonPowerBudget — Electrical load analysis artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field


class Voltage(str, Enum):
    v5 = "5V"
    v12 = "12V"
    v24 = "24V"
    v48 = "48V"

class PowerBudget(BaseModel):
    voltage: Voltage = Voltage.v12
    total_load_W: float = Field(default=50.0, gt=0.0)
    duty_cycle: float = Field(default=1.0, gt=0.0, le=1.0)
    safety_margin: float = Field(default=0.2, ge=0.0, le=1.0)
