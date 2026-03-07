from __future__ import annotations

from pydantic import BaseModel, Field

from Types.Monad.Observability.default import ObservabilityMonad
from Types.Monad.Error.default import PhaseId


class DiscoveryProductMeta(BaseModel):
    """[Product] — Discovery phase meta, Gas phase."""

    catalogs_queried: int = Field(
        default=0,
        ge=0,
        le=100,
        description="Catalogs queried",
    )
    api_calls: int = Field(
        default=0,
        ge=0,
        le=10000,
        description="External API calls made",
    )
    cache_hit: bool = Field(
        default=False,
        description="Results served from cache",
    )
    meta: ObservabilityMonad = Field(
        default_factory=lambda: ObservabilityMonad(phase=PhaseId.discovery),
        description="Observability data — errors, metrics, alarms, timing",
    )
