"""CoEvalProductOutput [CoProduct] — Eval observation result (5 fields). All bounded."""

from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
import uuid
from CoTypes.CoProduct.Eval.Meta.default import CoEvalProductMeta


class CoEvalProductOutput(BaseModel):
    """CoEvalProductOutput [CoProduct] — What was observed about an eval run (5 fields)."""

    observer_id: Annotated[str, StringConstraints(min_length=1, max_length=64)] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="Observer instance identifier",
    )
    eval_completed: bool = Field(
        default=False, description="Whether eval episode ran to completion"
    )
    return_recorded: bool = Field(
        default=False, description="Whether portfolio_return_pct was recorded"
    )
    render_logs_present: bool = Field(
        default=False, description="Whether render logs directory contains log files"
    )
    meta: CoEvalProductMeta = Field(
        default_factory=CoEvalProductMeta,
        description="Observation metadata — trace cursor",
    )
