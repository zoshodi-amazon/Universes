"""SigrokProtocolCapture — Bus/protocol trace artifact (5 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class BusProtocol(str, Enum):
    spi = "spi"; i2c = "i2c"; uart = "uart"; can = "can"; jtag = "jtag"
class ProtocolCapture(BaseModel):
    protocol: BusProtocol = BusProtocol.uart
    sample_rate_hz: int = Field(default=1_000_000, ge=1000, le=200_000_000)
    duration_s: float = Field(default=5.0, gt=0.0, le=3600.0)
    channels: int = Field(default=4, ge=1, le=32)
    trigger: bool = False
