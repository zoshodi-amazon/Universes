"""PythonPlantProfile — Botanical ID/properties artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class ClimateZone(str, Enum):
    tropical = "tropical"; temperate = "temperate"; arid = "arid"; arctic = "arctic"
class PlantUse(str, Enum):
    food = "food"; medicine = "medicine"; material = "material"; fuel = "fuel"
class PlantProfile(BaseModel):
    species: str = Field(default="unknown", description="Species identifier")
    primary_use: PlantUse = PlantUse.food
    climate: ClimateZone = ClimateZone.temperate
    days_to_harvest: int = Field(default=90, ge=1, le=730)
