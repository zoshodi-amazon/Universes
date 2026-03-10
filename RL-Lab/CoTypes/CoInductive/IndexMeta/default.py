"""CoIndexMetaInductive [CoInductive] — TickerInfo elimination witness (3 fields). All bounded.

Crystalline-dual — validates that a yfinance Ticker.info dict conforms to IndexMetaInductive.
"""

from pydantic import BaseModel, Field


class CoIndexMetaInductive(BaseModel):
    """CoIndexMetaInductive [CoInductive] — TickerInfo conformance witness (3 fields)."""

    fields_present: bool = Field(
        default=False,
        description="Whether all required info fields (symbol, exchange, etc.) are present",
    )
    types_valid: bool = Field(
        default=False,
        description="Whether field types match expected annotations (str, float, int)",
    )
    volume_positive: bool = Field(
        default=False, description="Whether averageVolume is present and positive"
    )
