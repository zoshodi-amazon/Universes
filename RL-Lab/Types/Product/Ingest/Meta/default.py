"""IngestProductMeta [Product] — Phase output meta extension for Ingest.

Bound to Ingest phase. Contains EffectMonad + ingest-specific audit fields.
"""
from pydantic import BaseModel, Field

from Types.Monad.Effect.default import EffectMonad
from Types.Monad.Error.default import PhaseId


class IngestProductMeta(BaseModel):
    """IngestProductMeta [Product] — Phase output meta extension for Ingest (6 fields)."""
    obs: EffectMonad = Field(
        default_factory=lambda: EffectMonad(phase=PhaseId.ingest),
        description="Observability data — errors, metrics, alarms, timing")
    cache_hit: bool = Field(default=False,
        description="Whether data was loaded from cache")
    raw_bar_count: int = Field(default=0, ge=0, le=10_000_000,
        description="Bars before warmup trimming")
    warmup_trimmed: int = Field(default=0, ge=0, le=100_000,
        description="Bars removed for indicator warmup")
    data_gaps_count: int = Field(default=0, ge=0, le=100_000,
        description="Number of detected gaps in time series")
    api_calls: int = Field(default=0, ge=0, le=1000,
        description="Number of yfinance API calls made")
