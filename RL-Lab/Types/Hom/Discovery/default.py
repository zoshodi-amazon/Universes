"""DiscoveryHom [Hom] — Discovery phase config (7 fields). All bounded.

io_indices is required — list of tickers to scan.
Empty list triggers yfinance screener fetch via `screener` field.
Interval comes from IndexIdentity, not here.
cache_dir lives on SessionIdentity (environment-level path fixpoint).

Fields satisfy Independence, Completeness, Locality:
- io_indices:          external ticker override — empty = use screener
- catalog_source:             screener name — only live when io_indices is empty
- min_trend_score:              trend qualification threshold — independent of lookback
- min_frame_length:             minimum data requirement — independent of ADX threshold
- trend_lookback:  how far back to fetch for ADX calculation — renamed from
                        'period' to distinguish from IngestHom.period (training lookback)
- liquidity:            liquidity filter config — sub-type, independent axis
- alarms:               alarm threshold config — sub-type, independent axis
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints

from Types.Dependent.Filter.default import FilterDependent
from Types.Dependent.Threshold.default import ThresholdDependent


class DiscoveryHom(BaseModel):
    """DiscoveryHom [Hom] — Config for asset discovery via screener and ADX trend filtering (7 fields)."""
    io_indices: list[Annotated[str, StringConstraints(pattern=r"^[A-Z0-9\-./=]{1,16}$", min_length=1, max_length=16)]] = Field(
        default_factory=list,
        description="Ticker list to scan — empty list triggers yfinance screener fetch")
    catalog_source: Annotated[str, StringConstraints(pattern=r"^[a-z_]+$", min_length=1, max_length=64)] = Field(
        default="most_actives",
        description="yfinance predefined screener query name — only used when io_indices is empty")
    min_trend_score: float = Field(default=20.0, ge=0.0, le=100.0,
        description="Minimum ADX (Average Directional Index) for trend qualification, 0-100")
    min_frame_length: int = Field(default=360, ge=1, le=100_000,
        description="Minimum number of price bars required to consider a ticker")
    trend_lookback: Annotated[str, StringConstraints(pattern=r"^\d{1,4}d$", min_length=2, max_length=5)] = Field(
        default="60d",
        description="Lookback period for ADX data fetch — e.g. 60d. Distinct from IngestHom.period (training lookback)")
    liquidity: FilterDependent = Field(default_factory=FilterDependent,
        description="Relative liquidity filters — percentile-based for asset-agnostic operation")
    alarms: ThresholdDependent = Field(default_factory=ThresholdDependent,
        description="Configurable alarm thresholds for observability")
