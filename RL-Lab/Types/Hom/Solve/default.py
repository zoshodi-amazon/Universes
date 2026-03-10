"""SolveHom [Hom] — Train phase config (7 fields). All bounded.

MlpPolicy hardcoded (always correct for flat obs). n_parallel for parallel sim envs.
SolverInductive imported from Inductive/Algo — it is an ADT (sum type), Crystalline phase.

Fields satisfy Independence, Completeness, Locality:
- solver:                 RL algorithm choice — independent axis
- n_parallel:               parallelism — independent of algorithm
- learning_rate:        optimizer step size — independent axis
- budget:      training budget — independent axis
- horizon_min: episode horizon — independent axis
- normalize_input:        obs normalisation flag — independent of reward norm
- normalize_signal:     reward normalisation flag — independent of obs norm
"""
from pydantic import BaseModel, Field

from Types.Inductive.Solver.default import SolverInductive


class SolveHom(BaseModel):
    """SolveHom [Hom] — Config for RL model training with SB3 (Stable-Baselines3)."""
    solver: SolverInductive = Field(default=SolverInductive.PPO,
        description="RL algorithm — PPO, SAC, DQN, or A2C")
    n_parallel: int = Field(default=1, ge=1, le=16,
        description="Parallel environment count — >1 uses SubprocVecEnv in sim mode")
    learning_rate: float = Field(default=3e-4, ge=1e-8, le=1.0,
        description="Optimizer step size — controls how fast the model updates weights")
    budget: int = Field(default=50_000, ge=100, le=100_000_000,
        description="Total training steps across all environments")
    horizon_min: int = Field(default=1440, ge=60, le=100_000,
        description="Max episode length in minutes — 1440 = one trading day")
    normalize_input: bool = Field(default=True,
        description="Whether to normalize observations via VecNormalize running stats")
    normalize_signal: bool = Field(default=True,
        description="Whether to normalize rewards via VecNormalize running stats")
