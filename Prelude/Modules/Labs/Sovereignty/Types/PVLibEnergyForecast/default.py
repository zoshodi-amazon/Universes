"""PVLibEnergyForecast — Solar/wind yield simulation artifact (4 params)"""
from pydantic import BaseModel, Field

class EnergyForecast(BaseModel):
    latitude: float = Field(default=30.0, ge=-90.0, le=90.0)
    longitude: float = Field(default=-97.0, ge=-180.0, le=180.0)
    panel_watts: float = Field(default=100.0, gt=0.0, le=10000.0)
    days: int = Field(default=7, ge=1, le=365)
