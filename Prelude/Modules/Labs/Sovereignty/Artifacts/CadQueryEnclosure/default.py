"""CadQueryEnclosure — Housing/case design artifact (5 params)"""
from enum import Enum
from pydantic import BaseModel, Field


class EnclosureMaterial(str, Enum):
    pla = "pla"
    petg = "petg"
    aluminum = "aluminum"
    acrylic = "acrylic"
    wood = "wood"

class MountType(str, Enum):
    none = "none"
    standoff = "standoff"
    rail = "rail"
    snap = "snap"

class Ventilation(str, Enum):
    none = "none"
    passive = "passive"
    active = "active"

class Enclosure(BaseModel):
    inner_width_mm: float = Field(default=80.0, gt=0.0)
    inner_height_mm: float = Field(default=50.0, gt=0.0)
    inner_depth_mm: float = Field(default=120.0, gt=0.0)
    material: EnclosureMaterial = EnclosureMaterial.pla
    mounting: MountType = MountType.standoff
