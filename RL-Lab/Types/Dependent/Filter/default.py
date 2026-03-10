"""FilterDependent [Dependent] — Relative liquidity filters for asset-agnostic discovery.

All filters are percentile/ratio-based, not absolute values.
This ensures the same config works across stocks, crypto, and forex.
"""
from pydantic import BaseModel, Field


class FilterDependent(BaseModel):
    """FilterDependent [Dependent] — Relative liquidity filters for asset-agnostic discovery (7 fields)."""
    min_volume_percentile: float = Field(default=30.0, ge=0.0, le=100.0,
        description="Ticker must be in top N% of peers by avg volume")
    min_price_percentile: float = Field(default=5.0, ge=0.0, le=100.0,
        description="Exclude bottom N% by price (penny stocks, dust)")
    max_spread_pct: float = Field(default=10.0, ge=0.0, le=100.0,
        description="Max daily range / close as volatility proxy — (day_high - day_low) / close * 100")
    min_turnover_pct: float = Field(default=0.1, ge=0.0, le=100.0,
        description="Min daily volume / market cap ratio")
    require_shortable: bool = Field(default=False,
        description="Only include assets that can be shorted")
    enabled: bool = Field(default=True,
        description="Enable liquidity filtering")
    min_universe_size: int = Field(default=5, ge=3, le=1000,
        description="Minimum number of tickers required before percentile filtering is applied")
