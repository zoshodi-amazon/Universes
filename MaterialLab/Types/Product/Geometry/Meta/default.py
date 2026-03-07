from __future__ import annotations

from pydantic import BaseModel, Field

from Types.Monad.Observability.default import ObservabilityMonad
from Types.Monad.Error.default import PhaseId


class GeometryProductMeta(BaseModel):
    """[Product] — Geometry phase meta, Gas phase."""

    csg_operations: int = Field(
        default=0,
        ge=0,
        le=100000,
        description="CSG operations performed",
    )
    parameters_used: int = Field(
        default=0,
        ge=0,
        le=100,
        description="Parametric parameters evaluated",
    )
    simplifications: int = Field(
        default=0,
        ge=0,
        le=10000,
        description="Features simplified/removed",
    )
    meta: ObservabilityMonad = Field(
        default_factory=lambda: ObservabilityMonad(phase=PhaseId.geometry),
        description="Observability data — errors, metrics, alarms, timing",
    )
