"""FeatureOutput [Gas] — Feature phase output (<=7 params). Self-contained."""
from pydantic import BaseModel, Field, constr
from Types.UnitTypes.FieldUnit.default import RunId, FilePath
import uuid

FeatureName = constr(pattern=r"^feature_[a-z_]+$", min_length=8, max_length=64)

class FeatureOutput(BaseModel):
    """FeatureOutput [Gas] — Result of feature engineering: wavelet-denoised OHLCV + trend indicators."""
    run_id: RunId = Field(default_factory=lambda: uuid.uuid4().hex[:8], description="8-char hex run identifier")
    n_static_features: int = Field(ge=1, le=100, description="Number of engineered feature columns (wavelet + trend)")
    n_dynamic_features: int = Field(ge=0, le=10, description="Number of gym-trading-env dynamic features (position state)")
    feature_names: list[FeatureName] = Field(max_length=100, description="Ordered list of feature column names, all prefixed feature_")
    n_valid_bars: int = Field(ge=1, le=100_000, description="Number of bars with valid features after engineering")
    io_data_path: FilePath = Field(..., description="File path to the persisted feature DataFrame pickle")
