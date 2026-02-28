"""NmapScanResult — Port/service scan artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class ScanTiming(str, Enum):
    sneaky = "sneaky"; polite = "polite"; normal = "normal"; aggressive = "aggressive"
class ScanResult(BaseModel):
    target: str = Field(default="192.168.1.0/24", description="Target CIDR/host")
    ports: str = Field(default="1-1024", description="Port range")
    protocol: str = Field(default="tcp", description="tcp|udp")
    timing: ScanTiming = ScanTiming.normal
