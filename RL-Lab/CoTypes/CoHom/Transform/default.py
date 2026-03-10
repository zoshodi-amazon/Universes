"""CoTransformHom [CoHom] — Feature phase observation spec (4 fields). All bounded.

Liquid-dual — observation specification parallel to TransformHom.
"""

from pydantic import BaseModel, Field


class CoTransformHom(BaseModel):
    """CoTransformHom [CoHom] — What to verify about a feature run (4 fields)."""

    wavelet_applied: bool = Field(
        default=True,
        description="Check that wavelet denoising was applied to all 5 OHLCV channels",
    )
    indicators_computed: bool = Field(
        default=True,
        description="Check that ADX and SuperTrend indicators were computed",
    )
    feature_prefix_enforced: bool = Field(
        default=True,
        description="Check that all feature columns start with 'feature_' prefix",
    )
    blob_persisted: bool = Field(
        default=True,
        description="Check that the feature blob was written to StoreMonad",
    )
