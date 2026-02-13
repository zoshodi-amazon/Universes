"""PythonCoverage — RF/sensor coverage overlay artifact (4 params)"""
from pydantic import BaseModel, Field

class Coverage(BaseModel):
    center_lat: float = Field(default=30.0, ge=-90.0, le=90.0)
    center_lon: float = Field(default=-97.0, ge=-180.0, le=180.0)
    radius_km: float = Field(default=10.0, gt=0.0, le=500.0)
    frequency_mhz: float = Field(default=915.0, gt=0.0, le=6000.0)
