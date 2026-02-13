"""GNURadioSpectrum — Frequency domain capture artifact (5 params)"""
from enum import Enum
from pydantic import BaseModel, Field

class SpectrumFormat(str, Enum):
    csv = "csv"
    sigmf = "sigmf"

class Spectrum(BaseModel):
    freq_start_mhz: float = Field(default=88.0, ge=0.1, le=6000.0)
    freq_end_mhz: float = Field(default=108.0, ge=0.1, le=6000.0)
    bandwidth_khz: float = Field(default=200.0, gt=0.0, le=56000.0)
    gain_db: float = Field(default=30.0, ge=0.0, le=70.0)
    duration_s: float = Field(default=10.0, gt=0.0, le=3600.0)
