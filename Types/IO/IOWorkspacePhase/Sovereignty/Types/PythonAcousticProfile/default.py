"""PythonAcousticProfile — Room/environment acoustic response artifact (4 params)"""
from pydantic import BaseModel, Field

class AcousticProfile(BaseModel):
    impulse_length_ms: float = Field(default=500.0, gt=0.0, le=10000.0)
    sample_rate_hz: int = Field(default=44100, ge=8000, le=192000)
    channels: int = Field(default=1, ge=1, le=8)
    measurement_distance_m: float = Field(default=1.0, gt=0.0, le=100.0)
