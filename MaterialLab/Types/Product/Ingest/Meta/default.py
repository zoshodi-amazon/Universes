from __future__ import annotations

from pydantic import BaseModel, Field

from Types.Monad.Observability.default import ObservabilityMonad
from Types.Monad.Error.default import PhaseId


class IngestProductMeta(BaseModel):
    """[Product] — Ingest phase meta, Gas phase."""

    parse_time_s: float = Field(
        default=-1.0,
        ge=-1.0,
        le=1e6,
        description="File parse time (sentinel -1.0 = not set)",
    )
    repair_applied: bool = Field(
        default=False,
        description="Mesh repair was applied",
    )
    raw_vertex_count: int = Field(
        default=0,
        ge=0,
        le=100_000_000,
        description="Vertices before processing",
    )
    meta: ObservabilityMonad = Field(
        default_factory=lambda: ObservabilityMonad(phase=PhaseId.ingest),
        description="Observability data — errors, metrics, alarms, timing",
    )
