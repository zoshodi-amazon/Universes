"""SlicerToolpath — Machine instructions artifact (5 params)"""
from enum import Enum
from pydantic import BaseModel, Field


class PrinterType(str, Enum):
    fdm = "fdm"
    sla = "sla"
    sls = "sls"

class Toolpath(BaseModel):
    printer: PrinterType = PrinterType.fdm
    layer_height_mm: float = Field(default=0.2, gt=0.0, le=1.0)
    speed_mm_s: float = Field(default=60.0, gt=0.0, le=300.0)
    temperature_c: int = Field(default=210, ge=150, le=300)
    retraction_mm: float = Field(default=1.0, ge=0.0, le=10.0)
