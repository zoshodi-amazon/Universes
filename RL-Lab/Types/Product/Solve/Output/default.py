"""SolveProductOutput [Product] — Train phase output (5 fields). Self-contained.

io_model_path and io_normalize_path removed: both were manual foreign keys into
the ad-hoc Env/ filesystem store. Artifact locations are now managed by
StoreMonad — the model blob is stored under artifact_type="model" and the
normalize blob under artifact_type="normalize", both keyed by session_id.
The type records only what the phase computed, not where it stored things.

SolverInductive imported from Inductive/Algo — it is an ADT (sum type), Crystalline phase.
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
from Types.Inductive.Solver.default import SolverInductive
from Types.Product.Solve.Meta.default import SolveProductMeta
import uuid


class SolveProductOutput(BaseModel):
    """SolveProductOutput [Product] — Result of RL training: algorithm, timesteps, reward (5 fields)."""
    session_id: Annotated[str, StringConstraints(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="8-char hex run identifier")
    solver: SolverInductive = Field(...,
        description="RL algorithm used for training — PPO, SAC, DQN, or A2C")
    budget: int = Field(ge=1, le=100_000_000,
        description="Total training steps completed across all environments")
    final_reward: float = Field(ge=-1e6, le=1e6,
        description="Last recorded reward from the training environment")
    meta: SolveProductMeta = Field(default_factory=SolveProductMeta,
        description="Train metadata: observability + audit")
