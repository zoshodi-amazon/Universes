"""CoSolveProductOutput [CoProduct] — Train observation result (5 fields). All bounded."""

from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
import uuid
from CoTypes.CoProduct.Solve.Meta.default import CoSolveProductMeta


class CoSolveProductOutput(BaseModel):
    """CoSolveProductOutput [CoProduct] — What was observed about a train run (5 fields)."""

    observer_id: Annotated[str, StringConstraints(min_length=1, max_length=64)] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="Observer instance identifier",
    )
    model_present: bool = Field(
        default=False, description="Whether model.zip blob exists on disk"
    )
    normalize_present: bool = Field(
        default=False, description="Whether VecNormalize stats blob exists"
    )
    reward_finite: bool = Field(
        default=False, description="Whether final_reward is a finite number"
    )
    meta: CoSolveProductMeta = Field(
        default_factory=CoSolveProductMeta,
        description="Observation metadata — trace cursor",
    )
