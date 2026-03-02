"""AssetUnit [Solid] — Asset-agnostic index type (6 params). All bounded.

Determines temporal structure: trade hours, holidays, interval.
Used by all phases. io_ticker is required.
"""
from enum import Enum
from pydantic import BaseModel, Field
from Types.UnitTypes.FieldUnit.default import Ticker


class AssetType(str, Enum):
    """Asset class category — stocks, crypto, or foreign exchange."""
    stock = "stock"
    crypto = "crypto"
    forex = "forex"


class HolidayCalendar(str, Enum):
    """Market holiday schedule — determines non-trading days."""
    none = "none"
    us_market = "us_market"
    bank = "bank"


class AssetUnit(BaseModel):
    """AssetUnit [Solid] — Asset-agnostic index type defining ticker, interval, and trade window."""
    asset_type: AssetType = Field(default=AssetType.stock, description="Asset class — stock, crypto, or forex")
    io_ticker: Ticker = Field(..., description="Ticker symbol — required external input, e.g. AAPL, BTC-USD")
    interval_min: int = Field(default=5, ge=1, le=1440, description="Bar interval in minutes — must be one of 1, 5, 15, 30, 60, 1440")
    trade_start_min: int = Field(default=570, ge=0, le=1440, description="Market open as minutes from midnight — 570 = 9:30 AM")
    trade_end_min: int = Field(default=960, ge=0, le=1440, description="Market close as minutes from midnight — 960 = 4:00 PM")
    holidays: HolidayCalendar = Field(default=HolidayCalendar.us_market, description="Holiday calendar for skipping non-trading days")
