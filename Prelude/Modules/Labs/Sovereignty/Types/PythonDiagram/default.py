"""PythonDiagram — Technical drawing artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class DiagramType(str, Enum):
    flowchart = "flowchart"; sequence = "sequence"; block = "block"; er = "er"
class DiagramFormat(str, Enum):
    svg = "svg"; png = "png"; d2 = "d2"
class Diagram(BaseModel):
    diagram_type: DiagramType = DiagramType.block
    elements: int = Field(default=5, ge=1, le=500)
    format: DiagramFormat = DiagramFormat.svg
