"""DiscoveryInput [Liquid] — Discovery phase config (<=7 params). All bounded.

io_universe is required — list of tickers to scan.
Empty list triggers yfinance screener fetch via `screener` field.
Interval comes from AssetUnit, not here.
"""
from pydantic import BaseModel, Field, constr
from Types.UnitTypes.FieldUnit.default import Ticker, DirPath

ScreenerName = constr(pattern=r"^[a-z_]+$", min_length=1, max_length=64)

class DiscoveryInput(BaseModel):
    """DiscoveryInput [Liquid] — Config for asset discovery via screener and ADX trend filtering."""
    io_universe: list[Ticker] = Field(..., description="Ticker list to scan — empty list triggers yfinance screener fetch")
    screener: ScreenerName = Field(default="most_actives", description="yfinance predefined screener query name, e.g. most_actives")
    min_adx: float = Field(default=25.0, ge=0.0, le=100.0, description="Minimum ADX (Average Directional Index) for trend qualification, 0-100")
    min_bars: int = Field(default=360, ge=1, le=100_000, description="Minimum number of price bars required to consider a ticker")
    period: constr(pattern=r"^\d{1,4}d$", min_length=2, max_length=5) = Field(default="60d", description="Lookback period for data fetch, e.g. 60d = 60 calendar days")
    cache_dir: DirPath = Field(default="Env/Inputs/cache", description="Directory for caching downloaded price data")
