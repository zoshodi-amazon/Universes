"""KiCadSchematic — Circuit diagram artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field


class SchematicFormat(str, Enum):
    kicad_sch = "kicad_sch"
    pdf = "pdf"
    svg = "svg"

class AnnotationStyle(str, Enum):
    reference = "reference"
    value = "value"
    both = "both"

class Schematic(BaseModel):
    components: int = Field(default=10, ge=1, le=1000)
    nets: int = Field(default=20, ge=1, le=5000)
    format: SchematicFormat = SchematicFormat.kicad_sch
    annotation: AnnotationStyle = AnnotationStyle.both
