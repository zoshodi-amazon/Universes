"""FeatureInput [Liquid] — Feature phase config (7 params). All bounded."""
from enum import Enum
from pydantic import BaseModel, Field


class WaveletName(str, Enum):
    """Wavelet family for signal decomposition — db = Daubechies, sym = Symlet."""
    db4 = "db4"
    db6 = "db6"
    db8 = "db8"
    sym4 = "sym4"
    sym6 = "sym6"


class ThresholdMode(str, Enum):
    """Wavelet denoising threshold mode — soft shrinks coefficients, hard zeros them."""
    soft = "soft"
    hard = "hard"


class FeatureInput(BaseModel):
    """FeatureInput [Liquid] — Config for wavelet denoising and trend indicator feature engineering."""
    wavelet: WaveletName = Field(default=WaveletName.db4, description="Wavelet family — db4 (Daubechies-4) is default for smooth denoising")
    level: int = Field(default=4, ge=1, le=8, description="Wavelet decomposition depth — higher captures longer-term trends")
    threshold_mode: ThresholdMode = Field(default=ThresholdMode.soft, description="Denoising mode — soft (shrink) or hard (zero) small coefficients")
    adx_period: int = Field(default=14, ge=2, le=100, description="ADX (Average Directional Index) lookback period in bars")
    supertrend_period: int = Field(default=10, ge=2, le=100, description="SuperTrend indicator lookback period in bars")
    supertrend_multiplier: float = Field(default=3.0, ge=0.5, le=10.0, description="SuperTrend ATR (Average True Range) multiplier for band width")
    regime_threshold: float = Field(default=25.0, ge=0.0, le=100.0, description="ADX threshold for trend/range regime classification, 0-100")
