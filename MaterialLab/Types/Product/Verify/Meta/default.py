from __future__ import annotations

from pydantic import BaseModel, Field

from Types.Monad.Observability.default import ObservabilityMonad
from Types.Monad.Error.default import PhaseId


class VerifyProductMeta(BaseModel):
    """[Product] — Verify phase meta, Gas phase."""

    checks_run: int = Field(
        default=0,
        ge=0,
        le=10000,
        description="Total verification checks run",
    )
    checks_passed: int = Field(
        default=0,
        ge=0,
        le=10000,
        description="Checks that passed",
    )
    checks_failed: int = Field(
        default=0,
        ge=0,
        le=10000,
        description="Checks that failed",
    )
    meta: ObservabilityMonad = Field(
        default_factory=lambda: ObservabilityMonad(phase=PhaseId.verify),
        description="Observability data — errors, metrics, alarms, timing",
    )
