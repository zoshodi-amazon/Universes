"""KiCadCircuit — PCB layout artifact (5 params)"""
from enum import Enum
from pydantic import BaseModel, Field


class PCBFormat(str, Enum):
    kicad_pcb = "kicad_pcb"
    gerber = "gerber"

class Circuit(BaseModel):
    layers: int = Field(default=2, ge=1, le=16)
    width_mm: float = Field(default=100.0, gt=0.0)
    height_mm: float = Field(default=100.0, gt=0.0)
    trace_width_mm: float = Field(default=0.25, gt=0.0, le=5.0)
    via_size_mm: float = Field(default=0.8, gt=0.0, le=3.0)
