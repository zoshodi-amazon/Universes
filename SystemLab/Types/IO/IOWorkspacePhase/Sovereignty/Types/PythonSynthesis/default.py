"""PythonSynthesis — Generated waveform artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class Oscillator(str, Enum):
    sine = "sine"; square = "square"; saw = "saw"; noise = "noise"
class Synthesis(BaseModel):
    oscillator: Oscillator = Oscillator.sine
    frequency_hz: float = Field(default=440.0, ge=20.0, le=20000.0)
    duration_s: float = Field(default=1.0, gt=0.0, le=60.0)
    amplitude: float = Field(default=0.8, ge=0.0, le=1.0)
