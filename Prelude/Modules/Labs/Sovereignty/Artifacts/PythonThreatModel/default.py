"""PythonThreatModel — Signature exposure assessment artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel, Field


class Mode(str, Enum):
    nomadic = "nomadic"
    urban = "urban"
    base = "base"

class OpsecLayer(str, Enum):
    physical = "physical"
    signal = "signal"
    digital = "digital"
    social = "social"
    financial = "financial"
    temporal = "temporal"
    legal = "legal"

class ThreatModel(BaseModel):
    mode: Mode = Mode.nomadic
    domains: list[str] = Field(default=["energy", "water", "food", "shelter", "comms", "compute", "intelligence", "defense", "transport", "trade", "fabrication", "medical"])
    opsec_layers: list[OpsecLayer] = Field(default=[OpsecLayer.physical, OpsecLayer.signal, OpsecLayer.digital, OpsecLayer.financial])
