from __future__ import annotations

from pydantic import BaseModel, Field

from Types.Monad.Observability.default import ObservabilityMonad
from Types.Monad.Error.default import PhaseId


class MainProductMeta(BaseModel):
    """[Product] — Main phase meta, Gas phase."""

    phases_attempted: int = Field(
        default=0,
        ge=0,
        le=7,
        description="Phases attempted",
    )
    phases_skipped: int = Field(
        default=0,
        ge=0,
        le=7,
        description="Phases skipped",
    )
    sweep_iterations: int = Field(
        default=0,
        ge=0,
        le=1000,
        description="Parameter sweep iterations (0 = no sweep)",
    )
    meta: ObservabilityMonad = Field(
        default_factory=lambda: ObservabilityMonad(phase=PhaseId.main),
        description="Observability data — errors, metrics, alarms, timing",
    )
