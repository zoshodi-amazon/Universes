"""SB3RLPolicy — Trained RL control policy artifact (5 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class RLAlgorithm(str, Enum):
    ppo = "ppo"; sac = "sac"; td3 = "td3"; a2c = "a2c"
class RLPolicy(BaseModel):
    algorithm: RLAlgorithm = RLAlgorithm.ppo
    obs_dim: int = Field(default=12, ge=1, le=1000)
    act_dim: int = Field(default=6, ge=1, le=100)
    timesteps: int = Field(default=100000, ge=1000, le=100_000_000)
    hidden_layers: int = Field(default=2, ge=1, le=10)
