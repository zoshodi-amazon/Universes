"""TrainInput [Liquid] — Train phase config (7 params). All bounded.

MlpPolicy hardcoded (always correct for flat obs). n_envs for parallel sim envs.
"""
from enum import Enum
from pydantic import BaseModel, Field


class AlgoName(str, Enum):
    """RL algorithm — PPO (Proximal Policy Optimization), SAC (Soft Actor-Critic), DQN (Deep Q-Network), A2C (Advantage Actor-Critic)."""
    PPO = "PPO"
    SAC = "SAC"
    DQN = "DQN"
    A2C = "A2C"


class TrainInput(BaseModel):
    """TrainInput [Liquid] — Config for RL model training with SB3 (Stable-Baselines3)."""
    algo: AlgoName = Field(default=AlgoName.PPO, description="RL algorithm — PPO, SAC, DQN, or A2C")
    n_envs: int = Field(default=1, ge=1, le=16, description="Parallel environment count — >1 uses SubprocVecEnv in sim mode")
    learning_rate: float = Field(default=3e-4, ge=1e-8, le=1.0, description="Optimizer step size — controls how fast the model updates weights")
    total_timesteps: int = Field(default=50_000, ge=100, le=100_000_000, description="Total training steps across all environments")
    episode_duration_min: int = Field(default=1440, ge=60, le=100_000, description="Max episode length in minutes — 1440 = one trading day")
    normalize_obs: bool = Field(default=True, description="Whether to normalize observations via VecNormalize running stats")
    normalize_reward: bool = Field(default=True, description="Whether to normalize rewards via VecNormalize running stats")
