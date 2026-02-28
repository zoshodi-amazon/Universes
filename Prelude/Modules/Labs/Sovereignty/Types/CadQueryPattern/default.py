"""CadQueryPattern — 2D cut/sew profile artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field


class PatternMaterial(str, Enum):
    acrylic = "acrylic"
    plywood = "plywood"
    leather = "leather"
    fabric = "fabric"
    cardboard = "cardboard"
    metal_sheet = "metal_sheet"

class PatternFormat(str, Enum):
    svg = "svg"
    dxf = "dxf"

class Pattern(BaseModel):
    material: PatternMaterial = PatternMaterial.acrylic
    thickness_mm: float = Field(default=3.0, gt=0.0, le=50.0)
    width_mm: float = Field(default=300.0, gt=0.0)
    height_mm: float = Field(default=300.0, gt=0.0)
