"""PythonControlLoop — PID/MPC controller config artifact (5 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class ControlType(str, Enum):
    pid = "pid"; mpc = "mpc"; lqr = "lqr"
class ControlLoop(BaseModel):
    controller: ControlType = ControlType.pid
    rate_hz: float = Field(default=100.0, gt=0.0, le=10000.0)
    kp: float = Field(default=1.0, ge=0.0, le=1000.0)
    ki: float = Field(default=0.1, ge=0.0, le=1000.0)
    kd: float = Field(default=0.01, ge=0.0, le=1000.0)
