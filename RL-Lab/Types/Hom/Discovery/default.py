"""DiscoveryHom [Hom] — Discovery phase config (7 fields). All bounded.

io_universe is required — list of tickers to scan.
Empty list triggers yfinance screener fetch via `screener` field.
Interval comes from AssetIdentity, not here.
cache_dir lives on RunIdentity (environment-level path fixpoint).

Fields satisfy Independence, Completeness, Locality:
- io_universe:          external ticker override — empty = use screener
- screener:             screener name — only live when io_universe is empty
- min_adx:              trend qualification threshold — independent of lookback
- min_bars:             minimum data requirement — independent of ADX threshold
- adx_lookback_period:  how far back to fetch for ADX calculation — renamed from
                        'period' to distinguish from IngestHom.period (training lookback)
- liquidity:            liquidity filter config — sub-type, independent axis
- alarms:               alarm threshold config — sub-type, independent axis
"""
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints

from Types.Dependent.Liquidity.default import LiquidityDependent
from Types.Dependent.Alarm.default import AlarmDependent


class DiscoveryHom(BaseModel):
    """DiscoveryHom [Hom] — Config for asset discovery via screener and ADX trend filtering (7 fields)."""
    io_universe: list[Annotated[str, StringConstraints(pattern=r"^[A-Z0-9\-./=]{1,16}$", min_length=1, max_length=16)]] = Field(
        default_factory=list,
        description="Ticker list to scan — empty list triggers yfinance screener fetch")
    screener: Annotated[str, StringConstraints(pattern=r"^[a-z_]+$", min_length=1, max_length=64)] = Field(
        default="most_actives",
        description="yfinance predefined screener query name — only used when io_universe is empty")
    min_adx: float = Field(default=20.0, ge=0.0, le=100.0,
        description="Minimum ADX (Average Directional Index) for trend qualification, 0-100")
    min_bars: int = Field(default=360, ge=1, le=100_000,
        description="Minimum number of price bars required to consider a ticker")
    adx_lookback_period: Annotated[str, StringConstraints(pattern=r"^\d{1,4}d$", min_length=2, max_length=5)] = Field(
        default="60d",
        description="Lookback period for ADX data fetch — e.g. 60d. Distinct from IngestHom.period (training lookback)")
    liquidity: LiquidityDependent = Field(default_factory=LiquidityDependent,
        description="Relative liquidity filters — percentile-based for asset-agnostic operation")
    alarms: AlarmDependent = Field(default_factory=AlarmDependent,
        description="Configurable alarm thresholds for observability")
