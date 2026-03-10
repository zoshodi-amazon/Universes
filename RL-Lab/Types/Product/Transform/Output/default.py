"""FeatureProductOutput [Product] — Feature phase output (6 fields). Self-contained.

io_data_path removed: was a manual foreign key into the ad-hoc Env/ filesystem
store. Artifact location is now managed by StoreMonad (DB row blob_path). The
type records only what the phase computed, not where it stored things.

n_valid_bars restored: Field Completeness — the Output records the computed result
(bars remaining after NaN-dropping). nan_rows_dropped in Meta records the process
audit (how many were removed). Both fields are required; they are not derivable
from each other.
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints
from Types.Product.Feature.Meta.default import FeatureProductMeta
import uuid


class FeatureProductOutput(BaseModel):
    """FeatureProductOutput [Product] — Result of feature engineering: wavelet-denoised OHLCV + trend indicators (6 fields)."""
    run_id: Annotated[str, StringConstraints(pattern=r"^[a-f0-9]{8}$", min_length=8, max_length=8)] = Field(
        default_factory=lambda: uuid.uuid4().hex[:8],
        description="8-char hex run identifier")
    n_static_features: int = Field(ge=1, le=100,
        description="Number of engineered feature columns (wavelet + trend)")
    n_dynamic_features: int = Field(ge=0, le=10,
        description="Number of gym-trading-env dynamic features (position state)")
    n_valid_bars: int = Field(ge=1, le=100_000,
        description="Bars remaining after NaN-dropping — the usable dataset size for training")
    feature_names: list[Annotated[str, StringConstraints(pattern=r"^feature_[a-z_]+$", min_length=8, max_length=64)]] = Field(
        default_factory=list, max_length=100,
        description="Ordered list of feature column names, all prefixed feature_")
    meta: FeatureProductMeta = Field(default_factory=FeatureProductMeta,
        description="Feature metadata: observability + audit")
