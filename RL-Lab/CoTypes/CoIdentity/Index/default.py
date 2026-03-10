"""CoIndexIdentity [CoIdentity] — Asset introspection witness (3 fields). All bounded.

BEC-dual — the coterminal dual of IndexIdentity. Witnesses whether the
asset identified by IndexIdentity is reachable, valid, and tradeable.
"""

from pydantic import BaseModel, Field


class CoIndexIdentity(BaseModel):
    """CoIndexIdentity [CoIdentity] — Asset reachability and validity witness (3 fields)."""

    ticker_valid: bool = Field(
        default=False,
        description="Whether io_ticker resolves to a known instrument via yfinance",
    )
    data_reachable: bool = Field(
        default=False,
        description="Whether OHLCV data can be fetched for this ticker and interval",
    )
    exchange_identified: bool = Field(
        default=False,
        description="Whether the exchange/market for this asset was identified",
    )
