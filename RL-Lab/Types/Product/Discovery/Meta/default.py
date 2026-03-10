"""DiscoveryProductMeta [Product] — Phase output meta extension for Discovery.

Bound to Discovery phase. Contains EffectMonad + discovery-specific audit fields.
"""

from pydantic import BaseModel, Field

from Types.Monad.Effect.default import EffectMonad
from Types.Monad.Error.default import PhaseId


class DiscoveryProductMeta(BaseModel):
    """DiscoveryProductMeta [Product] — Phase output meta extension for Discovery (6 fields)."""

    obs: EffectMonad = Field(
        default_factory=lambda: EffectMonad(phase=PhaseId.discovery),
        description="Observability data — errors, metrics, alarms, timing",
    )
    catalog_source_result_count: int = Field(
        default=0,
        ge=0,
        le=100_000,
        description="Raw count from catalog source before any filtering",
    )
    adx_filtered_count: int = Field(
        default=0, ge=0, le=100_000, description="Tickers filtered out by ADX threshold"
    )
    liquidity_filtered_count: int = Field(
        default=0,
        ge=0,
        le=100_000,
        description="Tickers filtered out by liquidity rules",
    )
    asset_class_filtered_count: int = Field(
        default=0,
        ge=0,
        le=100_000,
        description="Tickers filtered out by asset class routing",
    )
    top_adx_score: float = Field(
        default=-1.0,
        ge=-1.0,
        le=100.0,
        description="Highest ADX score among qualifying tickers, -1 if none",
    )
