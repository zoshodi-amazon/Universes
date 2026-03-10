"""SolveProductMeta [Product] — Phase output meta extension for Train.

Bound to Train phase. Contains EffectMonad + train-specific audit fields.
"""
from pydantic import BaseModel, Field

from Types.Monad.Effect.default import EffectMonad
from Types.Monad.Error.default import PhaseId


class SolveProductMeta(BaseModel):
    """SolveProductMeta [Product] — Phase output meta extension for Train (6 fields)."""
    obs: EffectMonad = Field(
        default_factory=lambda: EffectMonad(phase=PhaseId.solve),
        description="Observability data — errors, metrics, alarms, timing")
    episodes_completed: int = Field(default=0, ge=0, le=1_000_000,
        description="Number of training episodes completed")
    mean_episode_reward: float = Field(default=0.0, ge=-1e9, le=1e9,
        description="Mean reward across training episodes")
    std_episode_reward: float = Field(default=0.0, ge=0.0, le=1e9,
        description="Std dev of episode rewards")
    early_stopped: bool = Field(default=False,
        description="Whether training stopped early due to convergence")
    gpu_used: bool = Field(default=False,
        description="Whether GPU acceleration was used")
