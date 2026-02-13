"""PythonPropagation — RF path loss simulation artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field

class TerrainType(str, Enum):
    flat = "flat"
    urban = "urban"
    suburban = "suburban"
    forest = "forest"
    mountain = "mountain"

class Propagation(BaseModel):
    frequency_mhz: float = Field(default=915.0, gt=0.0, le=6000.0)
    power_dbm: float = Field(default=20.0, ge=-30.0, le=50.0)
    terrain: TerrainType = TerrainType.flat
    antenna_gain_dbi: float = Field(default=2.0, ge=-5.0, le=30.0)
