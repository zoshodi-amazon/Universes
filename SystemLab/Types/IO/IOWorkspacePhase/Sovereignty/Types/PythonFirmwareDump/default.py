"""PythonFirmwareDump — Extracted firmware binary artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class FlashInterface(str, Enum):
    spi = "spi"; i2c = "i2c"; jtag = "jtag"; uart = "uart"
class FirmwareDump(BaseModel):
    interface: FlashInterface = FlashInterface.spi
    size_bytes: int = Field(default=1_048_576, ge=256, le=1_073_741_824)
    base_addr: int = Field(default=0, ge=0)
    verify: bool = True
