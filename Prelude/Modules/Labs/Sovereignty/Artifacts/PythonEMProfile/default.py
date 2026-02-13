"""PythonEMProfile — Electromagnetic emission profile artifact (4 params)"""
from pydantic import BaseModel, Field

class EMProfile(BaseModel):
    freq_start_mhz: float = Field(default=1.0, ge=0.001, le=6000.0)
    freq_end_mhz: float = Field(default=1000.0, ge=0.001, le=6000.0)
    sensitivity_dbm: float = Field(default=-80.0, ge=-120.0, le=0.0)
    distance_m: float = Field(default=1.0, gt=0.0, le=1000.0)
