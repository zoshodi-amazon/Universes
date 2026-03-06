"""GNURadioWaveform — Time domain capture artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field

class WaveformFormat(str, Enum):
    wav = "wav"
    raw = "raw"
    sigmf = "sigmf"

class Waveform(BaseModel):
    sample_rate_hz: int = Field(default=2_400_000, ge=1000, le=56_000_000)
    channels: int = Field(default=2, ge=1, le=2)
    duration_s: float = Field(default=10.0, gt=0.0, le=3600.0)
    format: WaveformFormat = WaveformFormat.sigmf
