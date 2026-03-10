"""IndexIdentity [Identity] — Asset-agnostic index type (6 fields).

BEC phase — terminal object answering "what asset exists?"
Determines temporal structure: trade hours, holidays, interval.
Used by all phases. io_ticker is required.

Fields satisfy Independence, Completeness, Locality:
- index_class:      class of asset — stock, crypto, forex
- io_ticker:       external symbol — required IO boundary input
- interval_min:    bar granularity — independent time axis
- trade_start_min: market open — minutes from midnight
- trade_end_min:   market close — minutes from midnight
- holidays:        non-trading day calendar — independent of interval
"""
from enum import Enum
from typing import Annotated
from pydantic import BaseModel, Field, StringConstraints


class IndexClass(str, Enum):
    """Asset class category — stocks, crypto, or foreign exchange."""
    stock = "stock"
    crypto = "crypto"
    forex = "forex"


class TemporalMask(str, Enum):
    """Market holiday schedule — determines non-trading days."""
    none = "none"
    us_market = "us_market"
    bank = "bank"


class IndexIdentity(BaseModel):
    """IndexIdentity [Identity] — Asset-agnostic index type defining ticker, interval, and trade window."""
    index_class: IndexClass = Field(default=IndexClass.stock,
        description="Asset class — stock, crypto, or forex")
    io_ticker: Annotated[str, StringConstraints(pattern=r"^[A-Z0-9\-./=]{1,16}$", min_length=1, max_length=16)] = Field(
        ..., description="Ticker symbol — required external input, e.g. AAPL, BTC-USD, EURUSD=X")
    interval_min: int = Field(default=5, ge=1, le=1440,
        description="Bar interval in minutes — 1, 5, 15, 30, 60, or 1440")
    trade_start_min: int = Field(default=570, ge=0, le=1440,
        description="Market open as minutes from midnight — 570 = 9:30 AM")
    trade_end_min: int = Field(default=960, ge=0, le=1440,
        description="Market close as minutes from midnight — 960 = 4:00 PM")
    holidays: TemporalMask = Field(default=TemporalMask.us_market,
        description="Holiday calendar for skipping non-trading days")
