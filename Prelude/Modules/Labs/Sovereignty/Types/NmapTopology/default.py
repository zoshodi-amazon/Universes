"""NmapTopology — Network topology graph artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel, Field

class TopologyFormat(str, Enum):
    json = "json"
    svg = "svg"
    dot = "dot"

class Topology(BaseModel):
    scan_range: str = Field(default="192.168.1.0/24", description="CIDR range")
    depth: int = Field(default=2, ge=1, le=10)
    format: TopologyFormat = TopologyFormat.json
