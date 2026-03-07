from __future__ import annotations

from pydantic import BaseModel, Field

from Types.Monad.Observability.default import ObservabilityMonad
from Types.Monad.Error.default import PhaseId


class FabricationProductMeta(BaseModel):
    """[Product] — Fabrication phase meta, Gas phase."""

    slicer_used: str = Field(
        default="",
        min_length=0,
        max_length=32,
        description="Which slicer engine was used",
    )
    slice_time_s: float = Field(
        default=-1.0,
        ge=-1.0,
        le=1e6,
        description="Slicing time (sentinel -1.0 = not set)",
    )
    toolpath_moves: int = Field(
        default=0,
        ge=0,
        le=100_000_000,
        description="Number of toolpath moves",
    )
    meta: ObservabilityMonad = Field(
        default_factory=lambda: ObservabilityMonad(phase=PhaseId.fabrication),
        description="Observability data — errors, metrics, alarms, timing",
    )
