"""PythonMix — Multi-track audio composite artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class MixFormat(str, Enum):
    wav = "wav"; flac = "flac"
class Mix(BaseModel):
    tracks: int = Field(default=2, ge=1, le=64)
    sample_rate_hz: int = Field(default=44100, ge=8000, le=192000)
    format: MixFormat = MixFormat.wav
