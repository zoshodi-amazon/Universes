"""FeatureProductMeta [Product] — Phase output meta extension for Feature.

Bound to Feature phase. Contains ObservabilityMonad + feature-specific audit fields.
"""
from pydantic import BaseModel, Field

from Types.Monad.Observability.default import ObservabilityMonad
from Types.Monad.Error.default import PhaseId


class FeatureProductMeta(BaseModel):
    """FeatureProductMeta [Product] — Phase output meta extension for Feature (5 fields)."""
    obs: ObservabilityMonad = Field(
        default_factory=lambda: ObservabilityMonad(phase=PhaseId.feature),
        description="Observability data — errors, metrics, alarms, timing")
    wavelet_level_used: int = Field(default=4, ge=1, le=10,
        description="Wavelet decomposition level applied")
    nan_rows_dropped: int = Field(default=0, ge=0, le=100_000,
        description="Rows dropped due to NaN after feature engineering")
    regime_trending_pct: float = Field(default=0.0, ge=0.0, le=100.0,
        description="Percentage of bars classified as trending regime")
    feature_correlation_max: float = Field(default=0.0, ge=-1.0, le=1.0,
        description="Max pairwise correlation among features")
