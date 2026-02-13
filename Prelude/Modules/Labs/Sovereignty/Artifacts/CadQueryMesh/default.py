"""CadQueryMesh — 3D solid geometry artifact (6 params)"""
from enum import Enum
from pydantic import BaseModel, Field


class MeshMaterial(str, Enum):
    pla = "pla"
    petg = "petg"
    abs = "abs"
    tpu = "tpu"
    nylon = "nylon"
    resin = "resin"
    metal = "metal"

class MeshFormat(str, Enum):
    stl = "stl"
    step = "step"
    threemf = "3mf"

class Infill(str, Enum):
    hollow = "hollow"
    sparse = "sparse"
    medium = "medium"
    dense = "dense"
    solid = "solid"

class Mesh(BaseModel):
    material: MeshMaterial = MeshMaterial.pla
    resolution_mm: float = Field(default=0.2, gt=0.0, le=2.0)
    width_mm: float = Field(default=100.0, gt=0.0)
    height_mm: float = Field(default=100.0, gt=0.0)
    depth_mm: float = Field(default=100.0, gt=0.0)
    format: MeshFormat = MeshFormat.stl
