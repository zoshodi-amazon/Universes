"""PythonSequence — Frame sequence artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class SeqFormat(str, Enum):
    png = "png"; exr = "exr"
class Sequence(BaseModel):
    width_px: int = Field(default=1920, ge=64, le=7680)
    frame_count: int = Field(default=60, ge=1, le=100000)
    format: SeqFormat = SeqFormat.png
