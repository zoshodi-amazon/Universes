"""PythonServoConfig — Actuator specification artifact (6 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class ServoProtocol(str, Enum):
    pwm = "pwm"; serial = "serial"; canbus = "canbus"; ethercat = "ethercat"
class ServoConfig(BaseModel):
    torque_nm: float = Field(default=2.0, gt=0.0, le=500.0)
    speed_rpm: float = Field(default=60.0, gt=0.0, le=10000.0)
    voltage_v: float = Field(default=12.0, gt=0.0, le=48.0)
    protocol: ServoProtocol = ServoProtocol.pwm
    weight_g: float = Field(default=55.0, gt=0.0, le=5000.0)
    resolution_bits: int = Field(default=12, ge=8, le=20)
