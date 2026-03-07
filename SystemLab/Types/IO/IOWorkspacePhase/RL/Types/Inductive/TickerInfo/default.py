"""TickerInfoInductive [Inductive] — Structural validation for yfinance Ticker.info (6 fields).

Crystalline phase — validates Ticker.info dict with sentinel defaults.
"""
from typing import Any
from pydantic import BaseModel, Field


class TickerInfoInductive(BaseModel):
    """TickerInfoInductive [Inductive] — Validated ticker info."""
    symbol: str = Field(default="", max_length=20, description="Ticker symbol")
    average_volume: float = Field(default=-1.0, ge=-1.0, description="Average daily volume (-1.0 if unavailable)")
    regular_market_price: float = Field(default=-1.0, ge=-1.0, description="Current market price (-1.0 if unavailable)")
    day_high: float = Field(default=-1.0, ge=-1.0, description="Day high price (-1.0 if unavailable)")
    day_low: float = Field(default=-1.0, ge=-1.0, description="Day low price (-1.0 if unavailable)")
    market_cap: float = Field(default=-1.0, ge=-1.0, description="Market capitalization (-1.0 if unavailable)")

    @classmethod
    def from_info(cls, info: dict[str, Any] | None, symbol: str = "") -> "TickerInfoInductive":
        """Validate and convert Ticker.info dict."""
        if info is None:
            return cls(symbol=symbol)
        return cls(
            symbol=info.get("symbol", symbol) or symbol,
            average_volume=float(info.get("averageVolume", -1) or -1),
            regular_market_price=float(info.get("regularMarketPrice", -1) or info.get("previousClose", -1) or -1),
            day_high=float(info.get("dayHigh", -1) or -1),
            day_low=float(info.get("dayLow", -1) or -1),
            market_cap=float(info.get("marketCap", -1) or -1),
        )
