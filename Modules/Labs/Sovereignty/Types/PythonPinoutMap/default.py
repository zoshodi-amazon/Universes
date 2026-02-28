"""PythonPinoutMap — IC/connector pinout artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class PackageType(str, Enum):
    dip = "dip"; soic = "soic"; qfp = "qfp"; bga = "bga"; header = "header"
class PinoutFormat(str, Enum):
    svg = "svg"; json = "json"
class PinoutMap(BaseModel):
    package: PackageType = PackageType.dip
    pins: int = Field(default=8, ge=2, le=1000)
    labeled: bool = True
    format: PinoutFormat = PinoutFormat.svg
