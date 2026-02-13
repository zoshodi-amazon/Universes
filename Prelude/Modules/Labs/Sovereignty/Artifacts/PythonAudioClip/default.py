"""PythonAudioClip — Sound effect artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class AudioFormat(str, Enum):
    wav = "wav"; flac = "flac"; ogg = "ogg"
class AudioClip(BaseModel):
    sample_rate_hz: int = Field(default=44100, ge=8000, le=192000)
    channels: int = Field(default=1, ge=1, le=8)
    duration_s: float = Field(default=1.0, gt=0.0, le=600.0)
    format: AudioFormat = AudioFormat.wav
