"""PythonSensorFusion — Multi-sensor fusion config artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class FilterType(str, Enum):
    kalman = "kalman"; ekf = "ekf"; ukf = "ukf"; particle = "particle"
class SensorFusion(BaseModel):
    sensors: int = Field(default=3, ge=1, le=20)
    filter_type: FilterType = FilterType.ekf
    rate_hz: float = Field(default=100.0, gt=0.0, le=10000.0)
    state_dim: int = Field(default=6, ge=1, le=50)
