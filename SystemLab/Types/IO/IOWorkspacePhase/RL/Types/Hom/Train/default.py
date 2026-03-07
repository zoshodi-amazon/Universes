"""TrainHom [Hom] — Train phase config (7 fields). All bounded.

MlpPolicy hardcoded (always correct for flat obs). n_envs for parallel sim envs.
AlgoIdentity imported from Inductive/Algo — it is an ADT (sum type), Crystalline phase.

Fields satisfy Independence, Completeness, Locality:
- algo:                 RL algorithm choice — independent axis
- n_envs:               parallelism — independent of algorithm
- learning_rate:        optimizer step size — independent axis
- total_timesteps:      training budget — independent axis
- episode_duration_min: episode horizon — independent axis
- normalize_obs:        obs normalisation flag — independent of reward norm
- normalize_reward:     reward normalisation flag — independent of obs norm
"""
from pydantic import BaseModel, Field

from Types.Inductive.Algo.default import AlgoIdentity


class TrainHom(BaseModel):
    """TrainHom [Hom] — Config for RL model training with SB3 (Stable-Baselines3)."""
    algo: AlgoIdentity = Field(default=AlgoIdentity.PPO,
        description="RL algorithm — PPO, SAC, DQN, or A2C")
    n_envs: int = Field(default=1, ge=1, le=16,
        description="Parallel environment count — >1 uses SubprocVecEnv in sim mode")
    learning_rate: float = Field(default=3e-4, ge=1e-8, le=1.0,
        description="Optimizer step size — controls how fast the model updates weights")
    total_timesteps: int = Field(default=50_000, ge=100, le=100_000_000,
        description="Total training steps across all environments")
    episode_duration_min: int = Field(default=1440, ge=60, le=100_000,
        description="Max episode length in minutes — 1440 = one trading day")
    normalize_obs: bool = Field(default=True,
        description="Whether to normalize observations via VecNormalize running stats")
    normalize_reward: bool = Field(default=True,
        description="Whether to normalize rewards via VecNormalize running stats")
