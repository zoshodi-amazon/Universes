"""ProjectProductMeta [Product] — Phase output meta extension for Serve (6 fields).

shutdown_reason alias dissolved — constraint inlined on field.
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints

from Types.Monad.Effect.default import EffectMonad
from Types.Monad.Error.default import PhaseId


class ProjectProductMeta(BaseModel):
    """ProjectProductMeta [Product] — Phase output meta extension for Serve (6 fields)."""
    obs: EffectMonad = Field(
        default_factory=lambda: EffectMonad(phase=PhaseId.project),
        description="Observability data — errors, metrics, alarms, timing")
    broker_calls: int = Field(default=0, ge=0, le=10_000,
        description="Number of broker API calls made")
    broker_failures: int = Field(default=0, ge=0, le=10_000,
        description="Number of failed broker calls")
    orders_submitted: int = Field(default=0, ge=0, le=10_000,
        description="Number of orders submitted to broker")
    orders_filled: int = Field(default=0, ge=0, le=10_000,
        description="Number of orders confirmed filled")
    shutdown_reason: Annotated[str, StringConstraints(max_length=64)] = Field(default="",
        description="Reason for serve loop termination")
