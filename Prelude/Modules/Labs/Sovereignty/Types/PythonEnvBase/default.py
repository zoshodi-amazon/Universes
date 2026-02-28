"""PythonEnvBase — Execution environment context artifact (6 params)"""
from enum import Enum
from pydantic import BaseModel, Field
from pathlib import Path
class HardwareState(str, Enum):
    disconnected = "disconnected"; detected = "detected"; ready = "ready"
class NetworkState(str, Enum):
    offline = "offline"; local = "local"; mesh = "mesh"; internet = "internet"
class EnvBase(BaseModel):
    config_path: str = Field(default="default.json", description="Sovereignty config")
    output_dir: str = Field(default=".lab", description="Output directory")
    hardware: HardwareState = HardwareState.disconnected
    network: NetworkState = NetworkState.offline
    storage_path: str = Field(default=".lab/data", description="Persistent storage")
    log_level: str = Field(default="info", description="debug|info|warn|error")
